require_dependency 'query'
 
module QueryPatch

  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval do
      unloadable
      base.add_available_column(QueryColumn.new(:done_date, :sortable => "#{Issue.table_name}.done_date"))
      base.add_available_column(QueryColumn.new(:auditor_id, :sortable => "#{Issue.table_name}.auditor_id", :groupable => true))

      alias_method_chain :available_filters, :redmine_addons
      alias_method_chain :statement, :redmine_addons
    end
  end
  
  module InstanceMethods
    def statement_with_redmine_addons
      # filters clauses
      filters_clauses = []
      filters.each_key do |field|
        next if field == "subproject_id"
        v = values_for(field).clone
        next unless v and !v.empty?
        operator = operator_for(field)

        # "me" value subsitution
        if %w(assigned_to_id author_id watcher_id auditor_id).include?(field)
          v.push(User.current.logged? ? User.current.id.to_s : "0") if v.delete("me")
        end

        sql = ''
        if field =~ /^cf_(\d+)$/
          # custom field
          db_table = CustomValue.table_name
          db_field = 'value'
          is_custom_filter = true
          sql << "#{Issue.table_name}.id IN (SELECT #{Issue.table_name}.id FROM #{Issue.table_name} LEFT OUTER JOIN #{db_table} ON #{db_table}.customized_type='Issue' AND #{db_table}.customized_id=#{Issue.table_name}.id AND #{db_table}.custom_field_id=#{$1} WHERE "
          sql << sql_for_field(field, operator, v, db_table, db_field, true) + ')'
        elsif field == 'watcher_id'
          db_table = Watcher.table_name
          db_field = 'user_id'
          sql << "#{Issue.table_name}.id #{ operator == '=' ? 'IN' : 'NOT IN' } (SELECT #{db_table}.watchable_id FROM #{db_table} WHERE #{db_table}.watchable_type='Issue' AND "
          sql << sql_for_field(field, '=', v, db_table, db_field) + ')'
        elsif field == "member_of_group" # named field
          if operator == '*' # Any group
            groups = Group.all
            operator = '=' # Override the operator since we want to find by assigned_to
          elsif operator == "!*"
            groups = Group.all
            operator = '!' # Override the operator since we want to find by assigned_to
          else
            groups = Group.find_all_by_id(v)
          end
          groups ||= []

          members_of_groups = groups.inject([]) {|user_ids, group|
            if group && group.user_ids.present?
              user_ids << group.user_ids
            end
            user_ids.flatten.uniq.compact
          }.sort.collect(&:to_s)

          sql << '(' + sql_for_field("assigned_to_id", operator, members_of_groups, Issue.table_name, "assigned_to_id", false) + ')'

        elsif field == "assigned_to_role" # named field
          if operator == "*" # Any Role
            roles = Role.givable
            operator = '=' # Override the operator since we want to find by assigned_to
          elsif operator == "!*" # No role
            roles = Role.givable
            operator = '!' # Override the operator since we want to find by assigned_to
          else
            roles = Role.givable.find_all_by_id(v)
          end
          roles ||= []

          members_of_roles = roles.inject([]) {|user_ids, role|
            if role && role.members
              user_ids << role.members.collect(&:user_id)
            end
            user_ids.flatten.uniq.compact
          }.sort.collect(&:to_s)

          sql << '(' + sql_for_field("assigned_to_id", operator, members_of_roles, Issue.table_name, "assigned_to_id", false) + ')'
        else
          # regular field
          db_table = Issue.table_name
          db_field = field
          sql << '(' + sql_for_field(field, operator, v, db_table, db_field) + ')'
        end
        filters_clauses << sql

      end if filters and valid?

      filters_clauses << project_statement
      filters_clauses.reject!(&:blank?)

      filters_clauses.any? ? filters_clauses.join(' AND ') : nil
    end    
    
    def available_filters_with_redmine_addons
      return @available_filters if @available_filters

      trackers = project.nil? ? Tracker.find(:all, :order => 'position') : project.rolled_up_trackers

      auditor_users = (User.current.logged? ? [["<< #{l(:label_me)} >>", "me"]] : [])
      auditor_users << User.active.collect{|u| [u.name, u.id.to_s]}

      @available_filters = { "status_id" => { :type => :list_status, :order => 1, :values => IssueStatus.find(:all, :order => 'position').collect{|s| [s.name, s.id.to_s] } },
                             "tracker_id" => { :type => :list, :order => 2, :values => trackers.collect{|s| [s.name, s.id.to_s] } },
                             "priority_id" => { :type => :list, :order => 3, :values => IssuePriority.all.collect{|s| [s.name, s.id.to_s] } },
                             "subject" => { :type => :text, :order => 8 },
                             "created_on" => { :type => :date_past, :order => 9 },
                             "updated_on" => { :type => :date_past, :order => 10 },
                             "start_date" => { :type => :date, :order => 11 },
                             "due_date" => { :type => :date, :order => 12 },
                             "estimated_hours" => { :type => :integer, :order => 13 },
                             "done_ratio" =>  { :type => :integer, :order => 14 },
                             "auditor_id" => { :type => :list_optional, :order => 16, :values => auditor_users }
                             }

      user_values = []
      user_values << ["<< #{l(:label_me)} >>", "me"] if User.current.logged?
      if project
        user_values += project.users.sort.collect{|s| [s.name, s.id.to_s] }
      else
        all_projects = Project.visible.all
        if all_projects.any?
          # members of visible projects
          user_values += User.active.find(:all, :conditions => ["#{User.table_name}.id IN (SELECT DISTINCT user_id FROM members WHERE project_id IN (?))", all_projects.collect(&:id)]).sort.collect{|s| [s.name, s.id.to_s] }

          # project filter
          project_values = []
          Project.project_tree(all_projects) do |p, level|
            prefix = (level > 0 ? ('--' * level + ' ') : '')
            project_values << ["#{prefix}#{p.name}", p.id.to_s]
          end
          @available_filters["project_id"] = { :type => :list, :order => 1, :values => project_values} unless project_values.empty?
        end
      end
      @available_filters["assigned_to_id"] = { :type => :list_optional, :order => 4, :values => user_values } unless user_values.empty?
      @available_filters["author_id"] = { :type => :list, :order => 5, :values => user_values } unless user_values.empty?

      group_values = Group.all.collect {|g| [g.name, g.id.to_s] }
      @available_filters["member_of_group"] = { :type => :list_optional, :order => 6, :values => group_values } unless group_values.empty?

      role_values = Role.givable.collect {|r| [r.name, r.id.to_s] }
      @available_filters["assigned_to_role"] = { :type => :list_optional, :order => 7, :values => role_values } unless role_values.empty?

      if User.current.logged?
        @available_filters["watcher_id"] = { :type => :list, :order => 15, :values => [["<< #{l(:label_me)} >>", "me"]] }
      end

      if project
        # project specific filters
        categories = @project.issue_categories.all
        unless categories.empty?
          @available_filters["category_id"] = { :type => :list_optional, :order => 6, :values => categories.collect{|s| [s.name, s.id.to_s] } }
        end
        versions = @project.shared_versions.all
        unless versions.empty?
          @available_filters["fixed_version_id"] = { :type => :list_optional, :order => 7, :values => versions.sort.collect{|s| ["#{s.project.name} - #{s.name}", s.id.to_s] } }
        end
        unless @project.leaf?
          subprojects = @project.descendants.visible.all
          unless subprojects.empty?
            @available_filters["subproject_id"] = { :type => :list_subprojects, :order => 13, :values => subprojects.collect{|s| [s.name, s.id.to_s] } }
          end
        end
        add_custom_fields_filters(@project.all_issue_custom_fields)
      else
        # global filters for cross project issue list
        system_shared_versions = Version.visible.find_all_by_sharing('system')
        unless system_shared_versions.empty?
          @available_filters["fixed_version_id"] = { :type => :list_optional, :order => 7, :values => system_shared_versions.sort.collect{|s| ["#{s.project.name} - #{s.name}", s.id.to_s] } }
        end
        add_custom_fields_filters(IssueCustomField.find(:all, :conditions => {:is_filter => true, :is_for_all => true}))
      end
      @available_filters
    end
  end

end
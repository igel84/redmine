module Babylon2ProjectPatch
  def self.included(base)
    base.send(:include, ProjectInstanceMethods)
    base.class_eval do
      unloadable
      safe_attributes 'is_pr_closed','start_pr_date','end_pr_date'
      alias_method_chain :validate, :redmine_babylon2
    end
  end

  module ProjectInstanceMethods

    def validate_with_redmine_babylon2
      validate_without_redmine_babylon2
      if self.start_pr_date && self.end_pr_date
        errors.add '',l(:end_before_start) if self.start_pr_date > self.end_pr_date
      end
      if self.start_pr_date && self.parent && self.parent.start_pr_date
        errors.add '' , l(:start_before_parent) if self.start_pr_date < self.parent.start_pr_date
      end
      if self.end_pr_date && self.parent && self.parent.end_pr_date
        errors.add '' , l(:end_after_parent) if self.end_pr_date > self.parent.end_pr_date
      end
      if self.end_pr_date && !self.children.empty?
        maxdate = nil
        self.children.each do |ch|
          maxdate = ch.end_pr_date if ch.end_pr_date &&( !maxdate || (maxdate < ch.start_pr_date))
        end
        errors.add '', l(:end_before_subprojects) if self.end_pr_date < maxdate if maxdate
      end
      if self.start_pr_date && !self.children.empty?
        mindate=nil
        self.children.each do |ch|
          mindate = ch.start_pr_date if ch.start_pr_date &&( !mindate || (mindate > ch.start_pr_date))
        end
        errors.add '', l(:start_after_subprojects) if self.start_pr_date > mindate if mindate
      end
    end


    def get_start_date
      return self.start_pr_date if self.children.empty? || self.start_pr_date
      mindate=nil
      self.children.each do |ch|
        mindate = ch.start_pr_date if ch.start_pr_date &&( !mindate || (mindate > ch.start_pr_date))
      end
      mindate
    end

    def get_end_date
      return self.end_pr_date if self.children.empty? || self.end_pr_date
      maxdate=nil
      self.children.each do |ch|
        maxdate = ch.end_pr_date if ch.end_pr_date &&( !maxdate || (maxdate < ch.end_pr_date))
      end
      maxdate
    end

    def get_start_date_str
      date_to_dd_mm_yyyy(get_start_date)
    end

    def get_end_date_str
      date_to_dd_mm_yyyy(get_end_date)
    end

    def date_to_dd_mm_yyyy(date)
      return "-" unless date
      month = date.month.to_s
      month = "0" + month if month.length <2
      day = date.day.to_s
      day = "0" + day  if day.length <2
      day + "-" + month + "-" + date.year.to_s
    end

  end

end

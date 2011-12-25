module RedmineBabylon2
  class Hooks < Redmine::Hook::ViewListener

    render_on :view_projects_form, :partial =>'hooks/projects/formhook'#:file =>'fh' #'/projects/form_hook'
    render_on :view_users_form, :partial =>'hooks/users/user_formhook'


    #  Adds javascript and stylesheet tags
    def view_layouts_base_html_head(context)
      javascript_include_tag('projects_tree_view', :plugin => :redmine_ababylon2) +
      stylesheet_link_tag('projects_tree_view', :plugin => :redmine_ababylon2) +
      javascript_include_tag('calendar', :plugin => :redmine_ababylon2) +
      stylesheet_link_tag('calendar', :plugin => :redmine_ababylon2)+
      stylesheet_link_tag('style_bab2', :plugin => :redmine_ababylon2)
    end
    
    def controller_account_success_authentication_after(context={ })
      #redirect_to :controller => 'my', :action => 'page'
      #params[:back_url] = nil
    end
    
  end
end

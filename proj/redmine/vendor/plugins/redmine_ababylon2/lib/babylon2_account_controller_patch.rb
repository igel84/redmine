require_dependency 'account_controller'
module Babylon2AccountControllerPatch

  def self.included(base_class)
    base_class.send(:include, AccountControllerInstanceMethods)
    base_class.class_eval do
      alias_method_chain  :successful_authentication, :babylon2
    end
  end

  module AccountControllerInstanceMethods
    
    def successful_authentication_with_babylon2(user)
      # Valid user
      self.logged_user = user
      # generate a key and set cookie if autologin
      if params[:autologin] && Setting.autologin?
        set_autologin_cookie(user)
      end
      call_hook(:controller_account_success_authentication_after, {:user => user })
      redirect_to :controller => 'my', :action => 'page'
    end
    
  end


end

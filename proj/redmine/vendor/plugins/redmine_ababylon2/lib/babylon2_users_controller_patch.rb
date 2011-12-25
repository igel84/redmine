require_dependency 'users_controller'
module Babylon2UsersControllerPatch

  def self.included(base_class)
    base_class.send(:include, UsersControllerInstanceMethods)
    base_class.class_eval do
      alias_method_chain  :update, :babylon2
    end
  end

  module UsersControllerInstanceMethods

    def update_with_babylon2
      if params[:user][:stavka] && params[:user][:stavka]!=@user.stavka && User.current.get_access_rights_for_stavka_of(@user)<2
        flash[:error]="You can not set user stavka!!"
        redirect_to :back
      else
        update_without_babylon2
      end
    end

  end


end
module Babylon2UserPatch
  def self.included(base)
        base.class_eval do
    #      unloadable
          safe_attributes 'stavka'
        end
    base.send(:include, UserInstanceMethods)
  end

  module UserInstanceMethods

    def get_access_rights_for_stavka_of(user)
      # 0 -no access; 1-read only; 2-read&edit
      return 0 unless user && user.id
      s_right = StavkaRight.find(:first, :conditions=>["stavka_user_id=? AND user_id=?", user.id, self.id])
      return s_right.right if s_right
      return 2 if self.admin?
      return 1 if self.id==user.id
    end

  end

end

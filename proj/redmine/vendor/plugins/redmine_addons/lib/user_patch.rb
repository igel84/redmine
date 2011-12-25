require_dependency 'user'
 
module UserPatch

  def self.included(base)
    base.class_eval do
      safe_attributes 'jabber'
    end
  end

end
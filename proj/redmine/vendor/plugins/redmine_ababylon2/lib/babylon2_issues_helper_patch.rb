require_dependency 'issues_helper' 

module Babylon2IssuesHelperPatch
  def self.included(base) # :nodoc:    
    base.send(:include, InstanceMethods)     
    base.class_eval do      
      unloadable
    end
  end

  module InstanceMethods    
     def tmeth
       "TEST LSX HELPER"
     end
  end
end
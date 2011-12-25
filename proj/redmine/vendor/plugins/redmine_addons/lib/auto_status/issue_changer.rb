module AutoStatus
  
  class IssueChanger
    
    attr_accessor :params
    
    def initialize(issue, current_user)
      @issue = issue
      @user = current_user

      @params = Hash['attachments' => false]
    end
    
    def change(exist_time_entry = nil)
      processed_params = Hash['issue' => params]
      
      @time_entry = exist_time_entry || TimeEntry.new(:issue => @issue, :project => @issue.project)
      @notes = nil
      @issue.init_journal @user, @notes
      @issue.safe_attributes = processed_params['issue']
      @issue.save_issue_with_child_records processed_params, @time_entry
    end
    
    def save
      processed_params = Hash['issue' => params]

      @issue.init_journal @user, nil
      @issue.safe_attributes = processed_params['issue']
      @issue.save
    end
    
  end
  
end
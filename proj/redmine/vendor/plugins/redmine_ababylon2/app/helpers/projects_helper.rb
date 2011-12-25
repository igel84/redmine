module ProjectsHelper

  def rediness_percent(project)
    subprojects = Project.find(:all, :conditions=>['parent_id=?',project.id])
    top_ch_issues = ( subprojects.length>0 ? subprojects.inject([]){|r,p| r+p.issues.find_all{|i| i.root_id == i.id && !i.parent_id}} : project.issues.find_all{|i|  i.root_id == i.id && !i.parent_id}  )
    if top_ch_issues && top_ch_issues.length>0
      top_ch_issues.inject(0){|r,i| r+i.done_ratio}/top_ch_issues.length
    else
      100
    end
    #    ch_issues = ( project.leaf? ? project.issues.find_all{|i| ! i.children?} : project.leaves.inject([]){|r,p| r+p.issues.find_all{|i| ! i.children?}}  )
    #    total_estimated_hours = ch_issues.inject(0){|r,i| r+i.estimated_hours.to_f}
    #    av_estimated_hours = total_estimated_hours/ch_issues.count
    #    done_hours = ch_issues.inject(0){|r,i| r + ( i.estimated_hours ? i.estimated_hours : 0 )*( (i.closed? ? 1 : (i.done_ratio ? i.done_ratio.to_f/100 : 0)) )}
    #    (done_hours>0 ? (done_hours/total_estimated_hours*100).to_i : 0).to_s
  end
  
end
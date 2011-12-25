class StavkaRightsController < ApplicationController
  unloadable
  layout 'modal'#false

  def edit
    @user = User.find(params[:user_id])
    if !@user || User.current.get_access_rights_for_stavka_of(@user)<2
      render :text=>'Not enougth privileges to edit Stavka Permissions'
      return
    end
    @users = User.find(:all)
  end


  def update
    @user = User.find(params[:user_id])
    if !@user || User.current.get_access_rights_for_stavka_of(@user)<2
      render :text=>'Not enougth privileges to update Stavka Permissions'
      return
    end
    srights = params[:sright]
    txt = ""
    if srights
      srights.keys.each do |uid|
        txt +=  "  USER #{uid} R:" + srights[uid]
        s_right = StavkaRight.find(:first, :conditions=>["stavka_user_id=? AND user_id=?", @user.id, uid])
        if s_right
          s_right.right = srights[uid]
        else
          s_right = StavkaRight.new( :stavka_user_id => @user.id, :user_id => uid, :right => srights[uid] )
        end
        s_right.save
      end
    end
    render :inline=>"<script>opener.location.reload();self.close();</script>"
  end
 
end

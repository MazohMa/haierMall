class Backstage::AdminMessagesController < Backstage::BaseController
  layout "backstage/layouts/members"

  def list
    keyword = params[:keyword]
    if keyword.present?
      keyword = keyword.format_key
      # conditions = "users.mobile = #{keyword} or users."
      # join_sql = "left join dealers as d on d.user_id = admin_messages.user_id 
      #             left join shop_owners as s on s.user_id = admin_messages.user_id 
      #             where d.user_tel like '%#{keyword}%' or d.user_name like '%#{keyword}%' or d.company_name like '%#{keyword}%'
      #               or s.user_tel like '%#{keyword}%' or s.user_name like '%#{keyword}%' or s.company_name like '%#{keyword}%' "
      join_sql = "left join dealers as d on d.user_id = users.id 
                  left join shop_owners as s on s.user_id = users.id
                  left join admin_messages as a_m on a_m.user_id = users.id
                  where d.user_tel like '%#{keyword}%' or d.user_name like '%#{keyword}%' or d.company_name like '%#{keyword}%'
                    or s.user_tel like '%#{keyword}%' or s.user_name like '%#{keyword}%' or s.company_name like '%#{keyword}%' "
      @grid = AdminMessagesGrid.new(params[:admin_messages_grid]) do |scope|
       scope.joins(join_sql).group("users.id").order('a_m.created_at DESC').page(params[:page]).per(params[:page_size])
      end
    else
      @grid = AdminMessagesGrid.new(params[:admin_messages_grid]) do |scope|
         scope.joins(:admin_message).where("users.role in (?)",["dealer","shop_owner"]).group("users.id").order('admin_messages.created_at DESC').page(params[:page]).per(params[:page_size])
      end
    end
  end

  def show
    @user = User.find_by_id(params[:id])
    if @user.role == "dealer" or @user.role == "manufacturer"
      @user_info = @user.dealer
    else
      @user_info = @user.shop_owner
    end
    @user_role_name = AccessAuthority.find_by_id(@user.access_authority_id).remark
  end

  def approve
    user = User.find(params[:id])
    if Dealer.find_by_user_id(params[:id]).present?
      user.role = "dealer"
    else
      user.role = "shop_owner"
    end

    user.string="审核通过"

    if user.save
      push_approve_result(user)
      success_with_message("操作成功！")
    else
      failed_with_message("操作失败")
    end
  end

  def unapprove
    user = User.find(params[:id])
    user.string="审核失败"

    if user.save
      push_approve_result(user)
      success_with_message("操作成功！")
    else
      failed_with_message("操作失败")
    end
  end

  def push_approve_result(user)
    custom_content = {type: 1, created_at: Time.new.strftime("%Y-%m-%d %H:%M:%S") }
    #(user,title,description,custom_content)
    Util::Tool.push(user,"审核结果","审核通过",custom_content)
  end

  def new_user 
    #初始化数据
    # @roles = [{:key => "manufacturer" , :value => "厂商"},
    #           {:key => "dealer" , :value => "经销商"},
    #           {:key => "shop_owner" , :value => "终端店主"}]
    @roles = AccessAuthority.where(" name != ?", "admin").pluck(:name, :remark)
  end

  #系统添加用户
  def create_user
    #要区分经销商跟终端店主
    begin
      User.transaction do
        user = User.new(:mobile => params[:mobile], :password => params[:password], :username => params[:username],:string => "审核通过")
        if params[:role_select] == "dealer" or params[:role_select] == "manufacturer"
          user.role = "dealer"
          
          user.save!
          if params[:role_select] == "manufacturer"
            if authority = AccessAuthority.where("user_id=#{current_user.id} and remark='厂商'").first
              user.update(:access_authority_id => authority.id)
            end
          end
          
          AdminMessage.destroy_all("user_id = #{user.id}")
          AdminMessage.create(:user_id => user.id, :user_message => "系统添加")

          dealer = Dealer.create(:user_id => user.id, :company_name => params[:company_name], :user_name => params[:username],
                                  :user_address => params[:address], :user_email => params[:email],
                                  :user_phone => params[:phone], :user_fax => params[:fax],
                                  :user_tel => user.mobile, :user_manufacturer => params[:user_manufacturer],:user_model_num => params[:user_model_num])
          UserAuthorizationPic.create(:user_id => user.id, :image => params[:image])
          params[:distribution].each do |key,value|
            DeliveryArea.find_or_create_by(:dealer_id => dealer.id, :province_code => value[:province], :city_code => value[:city], :district_code => value[:area])
          end
        elsif params[:role_select] == "shop_owner"
          user.role = "shop_owner"
          user.save
          AdminMessage.destroy_all("user_id = #{user.id}")
          AdminMessage.create(:user_id => user.id, :user_message => "系统添加")

          shop_owner = ShopOwner.create(:user_id => user.id,:company_name => params[:company_name], :user_name => params[:username],
                                  :user_address => params[:address], :user_email => params[:email],
                                  :user_phone => params[:phone], :user_fax => params[:fax],
                                  :user_tel => user.mobile, :user_manufacturer => params[:user_manufacturer],:user_model_num => params[:user_model_num] )
          UserAuthorizationPic.create(:user_id => user.id, :image => params[:image])
        end
        redirect_to action: :list
        # success_with_message('创建成功') and return
      end
    rescue
      # failed_with_message('保存失败')
      redirect_to :back
    end    
  end

  #删除用户
  def destroy
    fail_title = ''
    params[:ids].each do |id|
      user = User.find_by_id(id.to_i)
      if !user.destroy
        fail_title += "#{user.mobile};</br>"
      end
    end
    
    if fail_title.present?
      failed_with_message("以下用户删除失败：</br>" + fail_title)
    else
      success_with_message("删除成功.")
    end
  end

end

class UserCouponPackagesGrid
  include Datagrid

  attr_accessor :coupon_package

  scope do 
    UserCouponPackage.includes(:user)
  end

  column(:row_number, header:'序号')

  column(:user_name,header:'用户名',order:false) do |model|
    user = model.user
    if user.role == "dealer"
      user.dealer.user_name if user.dealer.present?
    elsif user.role == "shop_owner"
      user.shop_owner.user_name if user.shop_owner.present?
    end
  end

  column(:mobile,header:'手机号',order:false) do |model|
    model.user.mobile
  end

  column(:role,header:'角色',order:false) do |model|
    AccessAuthority.find_by_id(model.user.access_authority_id).remark
  end

  column(:company_name,header:'公司名',order:false) do |model|
    user = model.user
    if user.role == "dealer"
      user.dealer.company_name if user.dealer.present?
    elsif user.role == "shop_owner"
      user.shop_owner.company_name if user.shop_owner.present?
    end
  end

  column(:status,header:'使用情况',order:false) do |model,grid|
    str = ''
    coupon_ids = grid.coupon_package.coupon_ids.split(",")
    have_use_num = 0
    UserGetCouponInformation.where(:user_id => model.user_id,:coupon_id => coupon_ids,:user_coupon_package_id => model.id).each do |coupon|
      have_use_num += 1 if coupon.status == 1
    end

    if have_use_num == 0
      str = "总共#{coupon_ids.count}张优惠券,还没使用"
    else
      str = "总共#{coupon_ids.count}张优惠券,已经使用#{have_use_num}张"
    end   
  end

end
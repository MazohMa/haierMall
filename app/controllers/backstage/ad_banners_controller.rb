class Backstage::AdBannersController < Backstage::BaseController
  layout 'backstage/layouts/system_setting'

  def index
    @grid = AdBannersGrid.new(params[:ad_banners_grid]) do |scope|
      scope.page(params[:page]).per(params[:page_size])
    end
  end

  def new
    @ad_banner = AdBanner.new
    @ad_locations = AdLocation.all
  end

  def create
    ad_banner = AdBanner.new(ad_banner_params)
    ad_banner.user_id = current_user.id

    if ad_banner.save
        images = params[:images].split(',')
        images.each do |image_id|
          image = AdBannerPicture.find_by_id(image_id)
          if image != nil
            image.ad_banner_id = ad_banner.id
            image.save
          end
        end
      redirect_to action: :index
    else
      render :new
    end
  end

  def show
    @ad_banner = AdBanner.find_by_id(params[:id])
  end

  def edit
    @ad_banner = AdBanner.find_by_id(params[:id])
    @product_name = ''
    #需要判断是否是首页
    if @ad_banner.ad_location_type == 1 and @ad_banner.product_id.present?
      product = Product.find_by_id(@ad_banner.product_id)
      @product_name = product.dealer.company_name + "的" + product.title
    end
  end

  def update
    ad_banner = AdBanner.find_by_id(params[:ad_banner][:id])
    if params[:ad_banner][:ad_location_type].to_i != 1 #需要判断是否是首页
      params[:ad_banner][:product_id] = ""
    end 
    if ad_banner.update_attributes(ad_banner_params)
      images = params[:images].split(',')
      images.each do |image_id|
        image = AdBannerPicture.find_by_id(image_id)
        if image != nil
          image.ad_banner_id = ad_banner.id
          image.save
        end
      end
      redirect_to action: :index
    else
      failed_with_message('操作失败')
    end
  end

  def destroy
    fail_title = ''
    params[:ids].each do |id|
      ad_banner = AdBanner.find_by_id(id.to_i)
      if !ad_banner.destroy
        title += "#{ad_banner.title};</br>"
      end
    end
    
    if fail_title.present?
      failed_with_message("以下广告删除失败：</br>" + fail_title)
    else
      success_with_message("删除成功.")
    end
  end

  def sent_picture
    pic = AdBannerPicture.new(:image => params[:file])
    if pic.save!
      success_with_result(pic.id)
    else
      failed_with_message("上传失败")
    end
  end

  def delete_picture
    pic = AdBannerPicture.find_by_id(params[:image_id])
    if pic.destroy
      success_with_result("删除成功")
    else
      failed_with_message("删除失败")
    end
  end

  #选择商品列表
  def ad_product_list
    brand_id = params[:brand]
    category_id = params[:category]

    keyword = "" 
    keyword = params[:keyword].format_key if params[:keyword].present?
 
    condition_sql = " status = 1 and period_of_validity > '#{Time.new}' "
    condition_sql << " and brand_id = #{brand_id}" if brand_id.present?
    condition_sql << " and category_id = #{category_id}" if category_id.present?
    condition_sql << " and ( title like '%#{keyword}%' or dealers.company_name like '%#{keyword}%')" if keyword.present?
    products = Product.joins(:product_categories, :dealer).where(condition_sql).group("products.id").order("products.created_at desc").page(params[:page]).per(params[:page_size])


    format_products = []
    products.each do |product|
      format_products << product.product_for_activity_to_json
    end

    success_with_result(:products =>format_products,
                                     :assets => { :total_pages => products.total_pages, :current_page => products.current_page,
                                     :next_page => products.next_page, :prev_page => products.prev_page,
                                     :first_page => products.first_page? , :last_page => products.last_page? } )
  end


  def ad_location_is_full
    max_num = 1
    max_num = 5 if params[:ad_location_type].to_i == 1

    #这个是给编辑的时候用。
    if AdBanner.where(:id => params[:id],:ad_location_type => params[:ad_location_type].to_i).first
      success_with_message("可以添加该广告位。") and return
    end

    if AdBanner.where(:ad_location_type => params[:ad_location_type].to_i).count < max_num
      success_with_message("可以添加该广告位。")
    else
      failed_with_message("该广告位已满，不能再添加了。")
    end
  end

  private
  def ad_banner_params
    params.require(:ad_banner).permit(:ad_location_type, :title, :manufacturer_id,:product_id, :color)
  end
end

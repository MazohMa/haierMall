require 'marketing'

class Backstage::CollocationsController < Backstage::BaseController
  layout 'backstage/layouts/marketing'
  include Marketing
  
  #套餐搭配只通过status来筛选，0未开始，1进行中，2已结束
  def all
    condition = ""
    collocations = CollocationPackage.where("dealer_id = #{current_dealer.id}")
    if params[:status]
      condition << "status =#{params[:status].to_i}"
    end
    @collocations= collocations.where(condition).page(params[:page]).per(params[:page_size]).order('updated_at desc')
  end

  def new
    @collocations = CollocationPackage.new
  end

  def create
    @collocations = CollocationPackage.new(collocation_params)
    @collocations.dealer_id = current_dealer.id
    @collocations.status = 0
    #再把套餐内容补充完整
      begin
        CollocationPackage.transaction do 
          @collocations.save
          if params[:images].present?
            params[:images].split(',').each do |id|
              if pic = PackagePicture.find(id.to_i)
                pic.collocation_package_id = @collocations.id
                pic.save
              end
            end
          end
          @collocations.create_collocation_contents(collocation_content_parmas)
          redirect_to action: :all
        end  
      rescue 
        render :new
      end
  end

  def edit
    if !(@collocations = CollocationPackage.find_by_id(params[:id].to_i))
      failed_with_message("找不到该记录")  and return
    end

    if !@collocations.can_be_update?
      failed_with_message("只有未开始的记录才能修改") and return
    end
    
    @format_content = []
    @collocations.collocation_contents.each do |content|
      @format_content << content.as_json
    end
  end

  def update
    if !(@collocations = CollocationPackage.find_by_id(params[:collocation_package][:id].to_i))
      failed_with_message("找不到该记录")  and return
    end

    if !@collocations.can_be_update?
      failed_with_message("只有未开始的记录才能修改") and return
    end

    if @collocations.update_attributes(collocation_params)

      @collocations.destroy_collocation_contents      
      @collocations.create_collocation_contents(collocation_content_parmas)

      if !params[:images].blank?
        images=params[:images].split(',')
        images.each do |image_id|
          image = PackagePicture.find_by_id(image_id)
          if image != nil
            image.collocation_package_id = @collocations.id
            image.save
          end
        end
      end
      redirect_to action: :all
    else
       failed_with_message("更新失败")
    end
  end


  def destroy
    if collocations = CollocationPackage.find_by_id(params[:id])
      if collocations.can_be_destroy?
        if collocations.destroy
          success_with_message("删除成功")
        else
          failed_with_message("删除失败")
        end
      else
        failed_with_message("只有未开始或已经终止的记录才能删除")
      end
    else
      failed_with_message("找不到该记录")
    end
  end

  def sent_product_picture
    pic = PackagePicture.new(:image=>params[:file])
    if pic.save
      success_with_result(pic.id)
    else
      failed_with_message("上传失败")
    end
  end

  def delete_product_picture
    nums =0
    params[:image_id].split(/,/).each do |pic_id|
      pic = PackagePicture.find_by_id(pic_id)
      if !pic.nil?
        pic.collocation_package_id = nil
        if pic.save
          nums += 1
        end
      end
    end
    success_with_result('成功删除:'+ nums.to_s) if nums >0
    failed_with_message("删除失败") if nums == 0
  end

  def enable
    result = true
    if coll = CollocationPackage.find_by_id(params[:id])
      coll.collocation_contents.pluck(:product_id).each do |product_id|
        product = Product.where("id = ? and status = ? and period_of_validity > ?",product_id, 1, Time.new).first
        if product.blank?
          result = false
          break
        end
      end if coll.collocation_contents.present?
    end
    if result == false
      failed_with_message("该套餐包含的商品已下架，无法启动。") and return
    end

    set_status("CollocationPackage" , "enable" , params[:id]) if params[:id].present?
    
  end

  def disable
    set_status("CollocationPackage" , "disable" , params[:id]) if params[:id].present?
  end

  private
  def collocation_params
    params.require(:collocation_package).permit(:title, :price, :original_price, :graphic_information)
  end

  #params["collocation_content"] 是记录参与套餐的商品信息，[{product_id: 1 , num: 3},{ ....}
  def collocation_content_parmas
    contents = []
    if params["collocation_content"].present?
        
      JSON.parse(params["collocation_content"]).each do |content|
        contents << content.slice(:prodouct_id, :num, :original_prices)
      end
    end
  end

end

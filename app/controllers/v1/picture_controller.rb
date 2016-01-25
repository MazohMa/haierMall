class V1::PictureController < V1::BaseController
	skip_before_filter :authenticate_session_user
	
	def create_pic
	  	if product_id = params[:product_id]
	  		pic = Picture.new(:image => params[:image] , :product_id =>product_id, :snapshoot_product_id => product_id)
	  		if pic.save
	  			success_with_result(pic)
	  		else
	  			failed_with_message("上传失败")
	  		end
	  	else
	  		failed_with_message('商品不存在')
	  	end
  	end

  	def delete_pic
	  nums = 0
	  params[:image_id].split(/,/).each do |pic_id|
  		pic = Picture.find_by_id(pic_id)
  		if !pic.nil?
		  pic.product_id = nil
		  if pic.save
			nums += 1
		  end
   		end
  	  end
	  success_with_result('成功删除:'+ nums.to_s)
  	end
end

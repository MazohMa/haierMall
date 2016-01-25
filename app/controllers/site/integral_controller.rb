require 'integration'
class Site::IntegralController < Site::BaseController
	before_filter :authenticate_user

	layout 'site/layouts/site'

	include Integration

	def integral
		if params[:type] == "2"
			@integration_records = IntegrationRecord.where(:user_id => current_user.id, :record_type => 2).order("created_at DESC").page(params[:page]).per(params[:page_size])
		else
			@integration_records = IntegrationRecord.where(:user_id => current_user.id).order("created_at DESC").page(params[:page]).per(params[:page_size])
		end
	end
	
	def exchange_product
    conditions = nil
		@product_type = params[:type]
		@member = current_user.member

    if params[:low_integration].present? and params[:high_integration].present?
      conditions = conditions_by_append(conditions, "integration >= #{params[:low_integration].to_i} and integration <= #{params[:high_integration].to_i}")
    end

		if @product_type == "2"
			
    	if conditions == nil
        @exchange_products = ExchangeProduct.filter_dealer(params[:delivery_area]).where("product_type = ? and validity_time <= ? and invalidity_time >= ? and status = 1",2,Time.new,Time.new).order("created_at desc").page(params[:page]).per(params[:page_size])
		  else
        @exchange_products = ExchangeProduct.filter_dealer(params[:delivery_area]).where("product_type = ? and validity_time <= ? and invalidity_time >= ? and status = 1",2,Time.new,Time.new).where(conditions).order("created_at desc").page(params[:page]).per(params[:page_size])
      end
    else
			if conditions == nil
        @exchange_products = ExchangeProduct.filter_dealer(params[:delivery_area]).where("product_type = ? and validity_time <= ? and invalidity_time >= ?",1,Time.new,Time.new).order("created_at desc").page(params[:page]).per(params[:page_size])
      else
        @exchange_products = ExchangeProduct.filter_dealer(params[:delivery_area]).where("product_type = ? and validity_time <= ? and invalidity_time >= ?",1,Time.new,Time.new).where(conditions).order("created_at desc").page(params[:page]).per(params[:page_size])
      end
		end		
	end

  def conditions_by_append(conditions, str)
    if conditions == nil
      return str
    else
      return conditions += " and #{str}"
    end
  end
	

end

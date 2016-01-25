class CartRecord < ActiveRecord::Base
	
	belongs_to :dealer
	validates_presence_of :product_id, :num, :user_id, :wholesale_id, :taste_id, :dealer_id

	belongs_to :product
	
	def as_json(options={})
		 super(:except => [:created_at, :updated_at]).merge({
		 	:product => self.product
	     })
	end
	
	
	
  def self.add_cart_record(user_id, product_id, product_nums, taste_id)
	taste = Taste.is_has_taste(product_id.to_i,taste_id.to_i).first
	return 2 if taste.nil?
    if cart_record = CartRecord.where( :product_id => product_id.to_i, :taste_id => taste_id.to_i,:user_id => user_id).first
	  cart_record.num = cart_record.num + product_nums.to_i
	  return 3 if taste.shipments < cart_record.num
	  Wholesale.where(:product_id => product_id.to_i).order("count desc").each do |wholesale|
		  if cart_record.num >= wholesale.count
			  cart_record.wholesale_id = wholesale.id
			  break 
		  end
	  end 
	  if cart_record.save
		  return cart_record
	  else
		  return 1
	  end  
    else
	  return self.sumit_cart_record(user_id, product_id, product_nums, taste.id)
    end
    
  end
  
  
  def self.sumit_cart_record(user_id, product_id, product_nums, taste_id)
	cart_record = self.create_cart_record(user_id, product_id, product_nums, taste_id)
	if cart_record.save
		return cart_record
	else
		return 1
	end
  end
  
  def self.create_cart_record(user_id, product_id, product_nums, taste_id)
	cart_record = CartRecord.new
	cart_record.user_id = user_id
	cart_record.product_id = product_id
	cart_record.num = product_nums
	cart_record.taste_id = taste_id
	cart_record.dealer_id = Product.find_by_id(product_id.to_i).dealer_id
	Wholesale.where(:product_id => product_id.to_i).order("count desc").each do |wholesale|
		if cart_record.num >= wholesale.count
			cart_record.wholesale_id = wholesale.id
			break
		end
	end
	if cart_record.wholesale_id.nil?
	  cart_record.wholesale_id = -1
	end
	return cart_record
  end
  
  
  def find_discount_price
	price = Order.find_product_price(self, Product.find_by_id(self.product_id))
	return format("%.2f",price * 0.1).to_f
  end
	
	
	
	
	
end

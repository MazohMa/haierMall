#encoding: utf-8
class InitializeInformation

  def create_user
    testuser = User.new(:mobile => "13266888888", :password => "123456", :role => 'dealer', :email => "dealerasd@qq.com")
    testuser2 = User.new(:mobile => "13266888888", :password => "123456", :role => 'dealer', :email => "dealerasd@qq.com")
    buyuser = User.new(:mobile => "13266888777", :password => "123456", :role => 'shop_owner', :email => "buyasd@qq.com")
    if testuser.save
     Dealer.create(:user_id => testuser.id, :company_name => "TestDealer")
     Session.create(:user_id => testuser.id, :token => "test123456")
    end
    
    if testuser2.save
      Dealer.create(:user_id => testuser2.id, :company_name => "T杰升科技")
      Session.create(:user_id => testuser2.id, :token => "test123456")
    end
    
    if buyuser.save
      ShopOwner.create(:user_id => buyuser.id, :brand_ids => 1)
      Session.create(:user_id => buyuser.id, :token => "buy123456")
    end
    
  end
  
  def create_brand
    Brand.create(:name => '伊利')
    Brand.create(:name => '蒙牛')
  end
  
  def create_category
    categories = ["牛奶", "雪条", "饮料", "雪糕杯"]
    categories.each do |category|
      Category.create(:category_name => category)
    end
  end

  def create_product
    nums = 1
      while nums < 200
        nums += 1
        product = Product.new
        product.title = "测试商品" + nums.to_s
        product.period_of_validity = "2015-02-" + rand(1..27).to_s
        product.brand_id = rand(1..2)
        product.is_share = rand(2)
        product.measurement = rand(1..2)
        product.province_code = 1
        product.city_code = 1
        product.delivery_deadline = rand(1..3)
        product.payment = "1,2,3,4"
        product.product_standard_num = "Q/NYLB " + rand(1000..10000).to_s
        product.production_license_num = "SN" + rand(100000..1000000).to_s
        product.pack_inside_num = rand(1..12)
        product.exp = rand(1..5)
        product.sale = rand(100)
        product.is_import = rand(2)
        product.organic_food = rand(2)
        product.new_product = rand(2)
        product.dealer_id = rand(1..2)
        product.manufacturer_id = rand(1..2)
        
        begin
          Product.transaction do
            p_num = price_nums
            wholesales = []
            wholesales << [p_num[0][2]+1.to_f,1]
            product.price = p_num[0][2]+1
            product.lowest_price = p_num[0][0]
            (0..2).each do |x|
              wholesales << [p_num[0][x], p_num[1][2-x]]  
            end
            product.save!
            
            category_id = rand(1..4)
            ProductCategory.create(:product_id => product.id, :category_id => category_id)
            
            product_taste = [["草莓味",rand(100..1000)], ["柠檬味", rand(100..1000)]]
            product_taste.each do |taste|
              Taste.create(:product_id => product.id, :title=> taste[0] , :shipments => taste[1]) 
            end
            
            wholesales.each do |wholesale|
              Wholesale.create(:product_id =>product.id , :count => wholesale[1] , :price => wholesale[0])
            end
          end
        rescue
          return "save error"
        end
      end
  end

  def price_nums
    price = []
    nums = []
    3.times {price << format("%.1f", rand(10..110) * 0.1).to_f}
    3.times {nums << rand(100)+1}
    return price.sort!,nums.sort!
  end

end

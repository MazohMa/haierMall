class Backstage::BrandsController < Backstage::BaseController

def all
  success_with_result(Brand.all)
end

end
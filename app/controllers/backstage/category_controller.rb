class Backstage::CategoryController < Backstage::BaseController

  def all
    success_with_result(Category.all)
  end

end
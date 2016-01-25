require 'rails_helper'

RSpec.describe Site::OrdersController, type: :controller do

  describe "GET #order_info" do
    it "returns http success" do
      get :order_info
      expect(response).to have_http_status(:success)
    end
  end

end

require 'rails_helper'

RSpec.describe Site::CartController, type: :controller do

  describe "GET #records" do
    it "returns http success" do
      get :records
      expect(response).to have_http_status(:success)
    end
  end

end

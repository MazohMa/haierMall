require 'rails_helper'

RSpec.describe UserController, :type => :controller do

  describe "GET login" do
    it "returns http success" do
      get :login
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET register" do
    it "returns http success" do
      get :register
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET find_password" do
    it "returns http success" do
      get :find_password
      expect(response).to have_http_status(:success)
    end
  end

end

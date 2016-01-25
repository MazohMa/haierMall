class Backstage::InformationController < ApplicationController
	layout 'backstage/layouts/backstage'
  def message
  	@informations_grid = InformationsGrid.new(params[:members_grid]) do |scope|
  		scope.page(params[:page]).per(params[:page_size]).add_row_number
	end

	@chats_grid = ChatsGrid.new(params[:chats_grid]) do |scope|
      scope.page(params[:page]).per(params[:page_size]).add_row_number
  end
  end

  def news
    @news_grid = NewsGrid.new(params[:news_grid]) do |scope|
  		scope.page(params[:page]).per(params[:page_size]).add_row_number
    end
  end
end

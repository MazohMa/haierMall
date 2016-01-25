class V1::CollocationsController < ApplicationController
  
  def details
    @collocations = CollocationPackage.find_by_id(params[:id].to_i)
  end
end

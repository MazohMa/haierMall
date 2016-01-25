class Backstage::UeditorController < Backstage::BaseController

  def ueditor_config
  		@@data= File.read("public/ueditor/config.json")
  		render :json => @@data
  end

  def uploadimage
      uploader = UeditorUploader.new 
      uploader.store!(params[:upfile])
      
  		result= {
  			:state =>"SUCCESS",
  			:url => uploader.url,
  			:title => params[:filename],
  			:original => params[:filename]
  		} 
  	  render :json => result,:content_type => 'text/plain' 	
  end
end



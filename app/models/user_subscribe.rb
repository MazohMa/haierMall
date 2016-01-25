class UserSubscribe < ActiveRecord::Base
  belongs_to :user
  
  
  def subscribe_sql
    sql = ""
    self.subscribe.split(',').each do |s|
      sql << "title like '%#{s}%' or "
    end
    if sql != ""
      sql.chomp!("or ")
    end
    sql
  end
  
  def user_adinformation(page,page_size)
    AdInformation.find_by_sql("SELECT  `ad_informations`.* FROM `ad_informations`  WHERE release_status = 1 and (#{subscribe_sql}) ORDER BY updated_at DESC LIMIT #{page_size} OFFSET #{page_size * page}")
  end
  
end

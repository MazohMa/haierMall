module Backstage::AbilityHelper
  
  def auth_format(ability)
    asd = ""
    format_html(ability,asd)
    asd << "<input style='display:none' id='server_abilities' name='access_authority[server_abilities]' type='text' value=''>"
  end
  
  def format_html(ability,asd,name=ability.first['description'])
    html = "<ul>"
      if ability.first.include?("id")
        ability.each do |e|
          unless e['id'].blank?
            html += "<li class='#{name}' style='display:none'> "
            html += "<input type='checkbox' name='#{name}' value='#{e["id"]}'/>"
            html += "<a href='javascript:void(0);'>#{e['name']}</a>" #@@server_abilities << Ability.new(:id => e['id'], :name => e['name'], :oprtation => e['oprtation']) unless e['id'].blank?
            html += "</li>"
          end
        end
        
      else
        ability.each do |x|
          if !x['name'].blank?
            admin_info = false
            ability.each {|e| admin_info = true and break if name == e["description"]}
            html += "<li class='#{admin_info ? "admin_info" : name} #{x["description"] ? "clickable" : ""}' value='#{x["description"] || " "}' style='display:none' >"
            html += "<input type='checkbox' name='#{x["description"] || " "}'/>"
            html += "<a href='javascript:void(0);'>---#{x['name']}---</a>"
            html += "</li>"
          end
          format_html(x["oprtation"],asd,x["description"]) if x.include?("oprtation")
        end
      end
    html += "</ul>"
    asd << html
  end
  
  def user_ability_html(ability,asd,name=ability.first['description'])
    html = "<ul>"
      if ability.first.include?("id")
        ability.each do |e|
          unless e['id'].blank?
            html += "<li class='#{name}' style='display:none'> "
            html += "<input type='checkbox' name='#{name}' value='#{e["id"]}' #{'checked="checked"' if check_bool(e['id'])}/>"
            html += "<a href='javascript:void(0);'>#{e['name']}</a>" 
            html += "</li>"
          end
        end
        
      else
        ability.each do |x|
          if !x['name'].blank?
            admin_info = false
            ability.each {|e| admin_info = true and break if name == e["description"]}
            html += "<li class='#{admin_info ? "admin_info" : name} #{x["description"] ? "clickable" : ""}' value='#{x["description"] || " "}' style='display:none' >"
            html += "<input type='checkbox' name='#{x["description"] || " "}' #{"checked='checked'" if check_ability(x["oprtation"])}/>"
            html += "<a href='javascript:void(0);'>---#{x['name']}---</a>"
            html += "</li>"
          end
          user_ability_html(x["oprtation"],asd,x["description"]) if x.include?("oprtation")
        end
      end
    html += "</ul>"
    asd << html
  end
  
  def check_ability(ability,bool=false)
    if ability.first.include?("id")
      ability.each do |e|
        unless e['id'].blank?
          return bool = true if check_bool(e['id'])
        end
      end
    else
      ability.each do |x|
        ck = check_ability(x["oprtation"],bool) if x.include?("oprtation")
        return ck if ck == true
      end
    end
    bool
  end
  
  def show_user(ability)
    asd = ""
    user_ability_html(ability,asd)
    asd << "<input style='display:none' name='id' type='text' value='#{@access_authority.id}'>"
    asd << "<input style='display:none' id='server_abilities' name='access_authority[server_abilities]' type='text' value=''>"
  end
  
  def find_access_authority
    AccessAuthority.find_by_id(params[:id]).server_abilities
  end
  
  def check_bool(id)
    find_access_authority.split(',').include?(id.to_s)
  end
  
end

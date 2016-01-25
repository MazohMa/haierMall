class Ability
  attr_accessor :id, :name, :oprtation
  @@abilities = YAML::load(File.open('./config/abilities.yml'))
  @@server_abilities = []

  def initialize(options={})
    @id = options[:id]
    @name = options[:name]
    @oprtation = options[:oprtation]
  end

  class << self

    def find_all_abilities(ability)
      if ability.first.include?("id")
        ability.each {|e| @@server_abilities << Ability.new(:id => e['id'], :name => e['name'], :oprtation => e['oprtation']) unless e['id'].blank?}
      else
        ability.each do |x|
          find_all_abilities(x["oprtation"]) if x.include?("oprtation")
        end
      end
    end
    
    def get_server_all_action
      find_all_abilities(@@abilities["server"]) if @@server_abilities == []
      result = []
      @@server_abilities.each do |s|
        s.oprtation.each {|e| result << e}
      end
      result
    end

    def find_abilities_by_ids(ids)
      find_all_abilities(@@abilities["server"]) if @@server_abilities == []
      if ids == []
        []
      else
        result = []
        @@server_abilities.each do |s|
          s.oprtation.each {|e| result << e } if ids.index(s.id.to_s)
        end
        result
      end
    end
    
    def all_abilities
      find_all_abilities(@@abilities["server"]) if @@server_abilities == []
      @@server_abilities
    end
    
    def format_abilities
      @@abilities
    end
    
    def find_by_ability_name(name)
      find_all_abilities(@@abilities["server"]) if @@server_abilities == []
      id = ""
      @@server_abilities.each do |e|
        if e.name == name
          id = e.id
          break
        end
      end
      id
    end
    
    
  end
end

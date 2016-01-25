class Unit
	attr_accessor :id, :name
	@@units = YAML::load(File.open('./config/unit.yml'))

	def initialize(options={})
		# @id = options[:id]
		# @name = options[:name]s
	end

	class << self
		def  get_measurement_unit
			@@units['measurement'].inject([]) {|result, e| result << [e['name'],  e['name']] ; result}
		end

		def get_net_wt_unit
			@@units['net_wt'].inject([]) {|result, e| result << [e['name'],  e['name']] ; result}
		end

		def get_specifications_unit
			@@units['specifications'].inject([]) {|result, e| result << [e['name'],  e['name']] ; result}
		end

		def get_payment_unit
			@@units['payment'].inject([]) {|result, e| result << [e['id'],  e['name']] ; result}
		end

		def get_delivery_deadline_unit
			@@units['delivery_deadline'].inject([]) {|result, e| result << [e['name'],  e['name']] ; result}
		end

		def get_pack_way_unit
			@@units['pack_way'].inject([]) {|result, e| result << [e['name'],  e['name']] ; result}
		end

		def get_exp_unit
			@@units['exp'].inject([]) {|result, e| result << [e['name'],  e['name']] ; result}
		end
	end

end
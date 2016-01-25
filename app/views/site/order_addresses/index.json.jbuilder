json.array!(@order_addresses) do |order_address|
  json.extract! order_address, :id, :order_id, :name, :mobile, :address, :zip_code
  json.url order_address_url(order_address, format: :json)
end

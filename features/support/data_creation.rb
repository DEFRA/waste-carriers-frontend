def create_complete_lower_tier_reg(type)
  registration =  JSON.parse(create_registration(type))
  id = registration['id']
  account_email = registration['accountEmail']

  create_user(account_email)
  return get_registration(id)
end

def create_complete_upper_tier_reg(type, method, copy_cards)
  registration =  JSON.parse(create_registration(type))
  id = registration['id']
  account_email = registration['accountEmail']

  create_user(account_email)

  #create order and pay
  order_response = JSON.parse(create_order(registration, copy_cards.to_i, method))
  create_payment(id, order_response['totalAmount'], account_email, method)

  return get_registration(id)
end

def create_registration(type)
  #post registration
  create_reg_file = File.read("features/fixtures/#{type}.json")
  create_reg_data = JSON.parse(create_reg_file)
  reg_uuid = SecureRandom.uuid
  create_reg_data['reg_uuid'] = reg_uuid

  url = "#{Rails.configuration.waste_exemplar_services_url}/registrations.json"
  create_reg_response = RestClient.post url, create_reg_data.to_json, :content_type => :json, :accept => :json

  #get variables to use later
  edit_reg_data = JSON.parse(create_reg_response)
  id = edit_reg_data['id']
  account_email = edit_reg_data['accountEmail']

  #edit registration
  edit_url = "#{Rails.configuration.waste_exemplar_services_url}/registrations/#{id}.json"
  edit_reg_response = RestClient.put edit_url, edit_reg_data.to_json, :content_type => :json, :accept => :json
  return edit_reg_response
end

def create_payment(id, amount, email, method)
  if method == "World Pay"
    payment_file = File.read("features/fixtures/payment_world_pay.json")
    payment_data = JSON.parse(payment_file)
    payment_data['updatedByUser'] = email
  else
    payment_file = File.read("features/fixtures/payment.json")
    payment_data = JSON.parse(payment_file)
  end
  current_date = DateTime.now
  payment_data['dateReceived_day'] = current_date.strftime('%-m')
  payment_data['dateReceived_month'] = current_date.strftime('%-d')
  payment_data['dateReceived_year'] = current_date.strftime('%Y')
  payment_data['dateReceived'] = current_date.strftime('%Y-%-m-%-d')
  payment_data['amount'] = amount

  payment_url = "#{Rails.configuration.waste_exemplar_services_url}/registrations/#{id}/payments.json"
  payment_response = RestClient.post payment_url, payment_data.to_json, :content_type => :json, :accept => :json
end

def create_order(edit_reg_response, no_of_copy_cards, method)
  edit_reg_response
  id = edit_reg_response['id']
  order_id = edit_reg_response['financeDetails']['orders'][0]['orderId']
  reg_identifier = edit_reg_response['regIdentifier']

  if method == "World Pay"
    order_file = File.read("features/fixtures/order_world_pay.json")
    order_data = JSON.parse(order_file)
  else
    order_file = File.read("features/fixtures/order_bank_transfer.json")
    order_data = JSON.parse(order_file)
  end

  order_data['orderId'] = order_id
  order_data['updatedByUser'] = edit_reg_response['accountEmail']
  order_data['dateCreated'] = DateTime.now.strftime('%FT%T%:z')
  total_amount = 15400

  order_data['orderItems'] << {
    "amount" => "15400",
    "currency" => "GBP",
    "description" => "Initial Registration",
    "reference" => "reg: #{reg_identifier}",
    "type" => "NEW"
  }
  if no_of_copy_cards > 0
    card_amount = no_of_copy_cards * 500
    total_amount = total_amount + card_amount
    order_data['orderItems'] << {
      "amount" => "#{card_amount.to_s}",
      "currency" => "GBP",
      "description" => "#{no_of_copy_cards.to_s}x Copy Cards",
      "reference" =>  "reg: #{reg_identifier}",
      "type" => "COPY_CARDS"
    }
  end

  order_data['totalAmount'] = total_amount
  order_url = "#{Rails.configuration.waste_exemplar_services_url}/registrations/#{id}/orders/#{order_id}.json"
  order_response = RestClient.put order_url, order_data.to_json, :content_type => :json, :accept => :json
  return order_response
end

def get_registration(id)
  get_reg_url = "#{Rails.configuration.waste_exemplar_services_url}/registrations/#{id}.json"
  get_reg_response = RestClient.get get_reg_url
  return JSON.parse(get_reg_response)
end

def create_user(account_email)
  user = User.new
  user.email = account_email
  user.password = 'test1234'
  user.confirmed_at = DateTime.now.strftime('%FT%T%:z')
  user.save
end
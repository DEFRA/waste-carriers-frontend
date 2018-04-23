def create_complete_lower_tier_reg(type)
  registration = create_complete_lower_tier_reg_from_hash(JSON.parse(File.read("features/fixtures/#{type}.json")))
  @cucumber_reg_id = registration['regIdentifier']
  return registration
end

def create_complete_lower_tier_reg_from_hash(reg_hash)
  create_user(reg_hash['accountEmail'])
  registration =  JSON.parse(create_registration_from_hash(reg_hash, nil, nil))
  return get_registration(registration['id'])
end

def create_complete_upper_tier_reg(type, method, copy_cards)
  registration = create_complete_upper_tier_reg_from_hash(JSON.parse(File.read("features/fixtures/#{type}.json")), method, copy_cards)
  @cucumber_reg_id = registration['regIdentifier']
  return registration
end

def create_complete_upper_tier_reg_from_IR(type, method, copy_cards)
  registration = create_complete_upper_tier_reg_from_hash(JSON.parse(File.read("features/fixtures/#{type}.json")), method, copy_cards)
  @cucumber_reg_id = registration['referenceNumber']
  return registration
end

def create_complete_upper_tier_reg_from_hash(reg_hash, method, copy_cards)
  registration =  JSON.parse(create_registration_from_hash(reg_hash, method, copy_cards))
  id = registration['id']
  account_email = registration['accountEmail']
  create_user(account_email)

  # Pay outstanding balance.
  money_owed = registration['financeDetails']['orders'][0]['totalAmount']
  order_code = registration['financeDetails']['orders'][0]['orderCode']
  create_payment(id, money_owed, account_email, method, order_code)
  return get_registration(id)
end

def create_registration(type)
  create_registration_from_hash(JSON.parse(File.read("features/fixtures/#{type}.json")))
end

def create_registration_from_hash(reg_hash, method, copy_cards)
  # Set expiry date for upper tier, as two years from today's date.
  if reg_hash['tier'] == 'UPPER'
    two_years_in_ms = 365 * 24 * 60 * 60 * 1000
    reg_hash['expires_on'] = ((Time.now.to_f * 1000) + two_years_in_ms).to_i
  end

  # Add finance details.
  reg_hash = add_finance_details_to_hash(reg_hash, copy_cards.to_i || 0, method)

  #post registration
  reg_hash['reg_uuid'] = SecureRandom.uuid
  url = "#{Rails.configuration.waste_exemplar_services_url}/registrations.json"
  create_reg_response = RestClient.post url, reg_hash.to_json, :content_type => :json, :accept => :json

  # "edit" registration (we only activiate during "edit", not "new" ?!)
  id = JSON.parse(create_reg_response)['id']
  edit_url = "#{Rails.configuration.waste_exemplar_services_url}/registrations/#{id}.json"
  edit_reg_response = RestClient.put edit_url, create_reg_response, :content_type => :json, :accept => :json
  return edit_reg_response
end

def create_payment(id, amount, email, method, order_code)
  if method == "World Pay"
    payment_file = File.read("features/fixtures/payment_world_pay.json")
    payment_data = JSON.parse(payment_file)
    payment_data['updatedByUser'] = email
    payment_data['orderKey'] = order_code
  else
    payment_file = File.read("features/fixtures/payment.json")
    payment_data = JSON.parse(payment_file)
  end
  current_date = DateTime.now
  payment_data['dateReceived_day'] = current_date.strftime('%-m')
  payment_data['dateReceived_month'] = current_date.strftime('%-d')
  payment_data['dateReceived_year'] = current_date.strftime('%Y')
  payment_data['dateReceived'] = current_date.strftime('%Y-%m-%d')
  payment_data['amount'] = amount

  payment_url = "#{Rails.configuration.waste_exemplar_services_url}/registrations/#{id}/payments.json"
  payment_response = RestClient.post payment_url, payment_data.to_json, :content_type => :json, :accept => :json
end

def add_finance_details_to_hash(reg_hash, no_of_copy_cards, method)
  order_data = nil
  total_amount = 0
  if reg_hash['tier'] == 'UPPER'
    if method == "World Pay"
      order_data = JSON.parse(File.read("features/fixtures/order_world_pay.json"))
    else
      order_data = JSON.parse(File.read("features/fixtures/order_bank_transfer.json"))
    end

    order_data['orderId'] = Time.zone.now.to_i.to_s
    order_data['updatedByUser'] = reg_hash['accountEmail']
    order_data['dateCreated'] = DateTime.now.strftime('%FT%T%:z')
    total_amount = 15400

    order_data['orderItems'] << {
      "amount"      => "15400",
      "currency"    => "GBP",
      "description" => "Initial Registration",
      "reference"   => "Initial registration",
      "type"        => "NEW"
    }

    if no_of_copy_cards > 0
      card_amount = no_of_copy_cards * 500
      total_amount = total_amount + card_amount
      order_data['orderItems'] << {
        "amount"      => "#{card_amount.to_s}",
        "currency"    => "GBP",
        "description" => "#{no_of_copy_cards.to_s}x Copy Cards",
        "reference"   =>  "Copy cards",
        "type"        => "COPY_CARDS"
      }
    end

    order_data['totalAmount'] = total_amount
  end

  reg_hash['financeDetails'] = {
    "orders"   => (reg_hash['tier'] == 'UPPER' ? [order_data] : nil),
    "balance"  => total_amount,
    "payments" => nil
  }

  return reg_hash
end

def get_registration(id)
  get_reg_url = "#{Rails.configuration.waste_exemplar_services_url}/registrations/#{id}.json"
  get_reg_response = RestClient.get get_reg_url
  return JSON.parse(get_reg_response)
end

def create_user(account_email)
  user = User.new
  user.email = account_email

  # Keep this in-sync with the value in world_extensions.rb
  user.password = 'Password123'
  user.skip_confirmation!
  user.save
end

def change_registration_id(new_reg_id)
  get_reg_url = "#{Rails.configuration.waste_exemplar_services_url}/registrations/#{@raw_id}.json"
  get_reg_response = RestClient.get get_reg_url
  parse_registration_hash = JSON.parse(get_reg_response)
  parse_registration_hash['regIdentifier'] = new_reg_id
  edit_url = "#{Rails.configuration.waste_exemplar_services_url}/registrations/#{@raw_id}.json"
  edit_reg_response = RestClient.put edit_url, parse_registration_hash.to_json, :content_type => :json, :accept => :json
  @irrenewl_id = new_reg_id
return edit_reg_response
end

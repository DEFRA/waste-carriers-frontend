json.array!(@agency_users) do |agency_user|
  json.extract! agency_user, :email
  json.url agency_user_url(agency_user, format: :json)
end
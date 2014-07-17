class FinanceDetails < Ohm::Model

  include ActiveModel::Conversion
  include ActiveModel::Validations
  extend ActiveModel::Naming

  attribute :balance

  set :orders, :Order
  set :payments, :Payment

end
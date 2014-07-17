class OrderItem < Ohm::Model

  include ActiveModel::Conversion
  include ActiveModel::Validations
  extend ActiveModel::Naming

  attribute :amount
  attribute :currency
  attribute :lastUpdated
  attribute :description
  attribute :reference

end
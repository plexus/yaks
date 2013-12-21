require 'virtus'
require 'yaks'
require 'json'

class Order
  include Virtus.model
  attribute :id, Integer
  attribute :basket_id, Integer
  attribute :customer_id, Integer
  attribute :total, Numeric
  attribute :currency, String
  attribute :status, String
end

class OrderSet
  include Virtus.model
  attribute :currently_processing, Integer
  attribute :shipped_today, Integer
  attribute :orders, Array[Order]
end

class OrderMapper < Yaks::Mapper
  link :self, '/orders/{id}'
  link :basket, '/baskets/{basket_id}'
  link :customer, '/baskets/{customer_id}'

  attributes :total, :currency, :status
end

class OrderSetMapper < Yaks::Mapper
  link :self, '/orders'
  link :curies, 'http://example.com/docs/rels/{rel}', name: "ea", expand: false
  link :"ea:find", "/orders{?id}", expand: false

  attributes :currentlyProcessing, :shippedToday

  has_many :orders, as: :"ea:order", mapper: OrderMapper

  def load_attribute(name)
    super(Yaks::Util.underscore(name.to_s))
  end
end

order_set = OrderSet.new(
  currently_processing: 14,
  shipped_today: 20,
  orders: [
    Order.new(
      id: 123,
      basket_id: 98712,
      customer_id: 7809,
      total: 30.00,
      currency: "USD",
      status: "shipped"
    ),
    Order.new(
      id: 124,
      basket_id: 97213,
      customer_id: 12369,
      total: 20.00,
      currency: "USD",
      status: "processing"
    )
  ]
)

resource = OrderSetMapper.new(order_set).to_resource

hal = Yaks::HalSerializer.new(resource).to_hal

puts JSON.dump(hal)

# {
#     "_links": {
#         "self": { "href": "/orders" },
#         "curies": [{ "name": "ea", "href": "http://example.com/docs/rels/{rel}", "templated": true }],
#         "next": { "href": "/orders?page=2" },
#         "ea:find": { "href": "/orders{?id}", "templated": true },
#         "ea:admin": [{
#             "href": "/admins/2",
#             "title": "Fred"
#         }, {
#             "href": "/admins/5",
#             "title": "Kate"
#         }]
#     },
#     "currentlyProcessing": 14,
#     "shippedToday": 20,
#     "_embedded": {
#         "ea:order": [{
#             "_links": {
#                 "self": { "href": "/orders/123" },
#                 "ea:basket": { "href": "/baskets/98712" },
#                 "ea:customer": { "href": "/customers/7809" }
#             },
#             "total": 30.00,
#             "currency": "USD",
#             "status": "shipped"
#         }, {
#             "_links": {
#                 "self": { "href": "/orders/124" },
#                 "ea:basket": { "href": "/baskets/97213" },
#                 "ea:customer": { "href": "/customers/12369" }
#             },
#             "total": 20.00,
#             "currency": "USD",
#             "status": "processing"
#         }]
#     }
# }

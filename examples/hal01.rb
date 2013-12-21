# http://stateless.co/hal_specification.html

# There are still some affordances missing to support all of HAL, in particular
# for this example to ability to generate links based on composite content
# (ea:admin) is not implemented, neither is explicit support for CURIEs (compact
# URI shorthand syntax), although this examples works around that by manually
# encoding the CURIE prefixes.

# The 'next' link from the example below is also ommitted, pagination is an aspect
# that will be implemented generically

# Example from the specification, approximated with Yaks below

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
  link :"ea:basket", '/baskets/{basket_id}'
  link :"ea:customer", '/customers/{customer_id}'

  attributes :total, :currency, :status
end

class OrderSetMapper < Yaks::Mapper
  link :self, '/orders'
  link :curies, 'http://example.com/docs/rels/{rel}', name: "ea", expand: false
  link :"ea:find", "/orders{?id}", expand: false

  attributes :currentlyProcessing, :shippedToday

  has_many :orders, as: :"ea:order", mapper: OrderMapper

  # Having the attributes be encoded in CamelCase is such a common
  # use case we might have to make this a setting

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

hal = Yaks::HalSerializer.new(resource, singular_links: [:self, :"ea:find", :"ea:basket", :"ea:customer"]).to_hal

puts JSON.dump(hal)

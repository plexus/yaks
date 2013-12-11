# Yankee Alpha Kilo Serializers

```ruby
class ShowSerializer < Yaks::Serializer
  attributes :id, :name, :description, :dates

  has_many :events
  has_one :event_category

  def description
    object.description(:long)
  end

  def dates
    events.map(&:day)
  end
end

class EventSerializer < Yaks::Serializer
  attributes :id, :name
end

class EventCategorySerializer < Yaks::Serializer
  attributes :id, :name
end

json = JSON.dump(
  Yaks::Dumper.new(format: :json_api).dump('shows', Show.upcoming)
)
```

## Non-Features

* No core extensions
* Minimal dependencies
* Only serializes what explicitly has a Serializer, will never call to_json/as_json
* Adding extra output formats does not require altering existing code
* Has no opinion on what to use for final JSON encoding (json, multi_json, yajl, oj, etc.)

## Formats

* :json_api

```json
{
   "shows" : [
      {
         "dates" : [ "next Sunday" ],
         "name" : "Piglet gets his groove back",
         "id" : 5,
         "description" : "Once in a lifetime...",
         "links" : {
            "event_category" : 2,
            "events" : [ 7 ]
         }
      }
   ],
   "linked" : {
      "event_categories" : [
         {
            "name" : "Drama",
            "id" : 2
         }
      ],
      "events" : [
         {
            "name" : "Sneak preview",
            "id" : 7
         }
      ]
   }
}
```

* :ams_compat

```json
{
   "shows" : [
      {
         "dates" : [ "next Sunday" ],
         "name" : "Piglet gets his groove back",
         "id" : 5,
         "description" : null,
         "event_ids" : [ 7 ],
         "event_category_id" : 2
      }
   ],
   "event_categories" : [{
         "name" : "Drama",
         "id" : 2
   }],
   "events" : [{
         "Name" : "Sneak preview",
         "id" : 7
   }]
}
```

## Maturity

Infantile. Crazy what these kids get up to.

requires current master of Hamster.

## License

MIT

require 'spec_helper'

module Yaks
  describe FoldJsonApi do
    let(:collection) {
      ResourceCollection.new(
        'friends',
        :id,
        Hamster.list(
          Resource.new(
            Hamster.hash(
              id: '3',
              name: 'john'
            ),
            Hamster.list(
              SerializableAssociation.new(
                ResourceCollection.new(
                  'pets', :id,
                  Hamster.list(
                    Resource.new(Hamster.hash(
                        id: '3',
                        pet_name: 'wabi'
                    ),
                      Hamster.list
                    ),
                    Resource.new(Hamster.hash(
                        id: '4',
                        pet_name: 'sabi'
                    ),
                      Hamster.list
                    )
                  )
                )
              )
            )
          )
        )
      )
    }

    specify do
      expect( FoldJsonApi.new(collection).fold ).to eq(
        Hamster.hash(
          "friends" => Hamster.list(
            Hamster.hash(
              "id" => "3",
              "name" => "john",
              "links" => Hamster.hash(
                "pets" => Hamster.list("3", "4")
              ),
            )
          ),
          "linked" => Hamster.hash(
            "pets" => Hamster.set(
              Hamster.hash("pet_name" => "sabi", "id" => "4"),
              Hamster.hash("pet_name" => "wabi", "id" => "3")
            )
          )
        )
      )
    end
  end
end

require 'spec_helper'

module PlexusSerializers
  describe JsonApiFolder do
    let(:collection) {
      SerializableCollection.new(
        'friends',
        :id,
        Hamster.list(
          SerializableObject.new(
            Hamster.hash(
              id: '3',
              name: 'john'
            ),
            Hamster.list(
              SerializableAssociation.new(
                SerializableCollection.new(
                  'pets', :id,
                  Hamster.list(
                    SerializableObject.new(Hamster.hash(
                        id: '3',
                        pet_name: 'wabi'
                    ),
                      Hamster.list
                    ),
                    SerializableObject.new(Hamster.hash(
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
      expect( JsonApiFolder.new(collection).fold ).to eq(
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

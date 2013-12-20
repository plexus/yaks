class FriendMapper < Yaks::Mapper
  attributes :id, :name

  link :copyright, '/api/copyright/{year}'

  def year
    2024
  end

  has_one :pet_peeve, mapper: PetPeeveMapper

  # has_one :production_company,          # retrieve as `show.production_company`
  #         profile: :company,            # use the company profile link from the registry, e.g. 'http://foo.api/profiles/company'
  #         as: :producer,                # serialize as {"producers" => []} in JSON-API or [{class: ["producer"]}] in Siren
  #         embed: :link,                 # don't embed the whole data, link to it, could also be embed: :resource
  #         mapper: CompanyMapper,        # use this to find the resource URL, or to map the embedded resource
  #         rel: :show_production_company # find the relation in the relation registry, e.g. http://foo.apo/rels/show_production_company

  # # Full derived defaults
  # has_one :production_company
  #   # profile: :production_company,  # same as the 'name'
  #   # as: :production_company,       # same as the 'name'
  #   # embed: :links                  # depends on what is configured as default
  #   # mapper: CompanyMapper          # found by matching the profile
  #   # rel: :show_production_company  # "#{context.profile_name}_#{relation.profile_name}"

  # # has_many :pets
end

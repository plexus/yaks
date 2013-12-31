module Yaks
  module LinkLookup

    def uri
      self_link = links_by_rel(:self).first
      self_link.uri if self_link
    end

    def profile
      link = links_by_rel(:profile).first
      link.uri if link
    end

    def profile_type
      profile_registry.find_by_uri(profile)
    end

    def links_by_rel(rel)
      links.select {|link| link.rel == rel}
    end

  end
end

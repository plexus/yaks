module Yaks
  module LinkLookup

    def profile
      link = links_by_rel(:profile).first
      link.uri if link
    end

    def links_by_rel(rel)
      links.select {|link| link.rel == rel}
    end

  end
end

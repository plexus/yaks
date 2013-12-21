module Yaks
  module CrossCutting
    def policy
      options[:policy]
    end

    def profile_registry
      options[:profile_registry]
    end
  end
end

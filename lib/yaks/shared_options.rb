module Yaks
  module SharedOptions
    def policy
      options[:policy]
    end

    def profile_registry
      options[:profile_registry]
    end

    def rel_registry
      options[:rel_registry]
    end
  end
end

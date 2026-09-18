# Trading identity for this storefront: name, tagline, contact addresses, and
# the canonical URL.
#
# Everything that needs the shop's own name reads it from here rather than
# hardcoding a string. That is what makes renaming the business a one-line
# change in config/store.yml rather than a find and replace across views,
# mailers and structured data.
#
# Environment variables override the file, so one build can serve staging and
# production without a code change.
#
# NAMING NOTE: this class is deliberately not called `Brand`. `Brand` is a
# canonical domain term in docs/domain-terms.md and refers to the maker of a
# Product, which is a different concept with its own table and model. Using one
# word for both is exactly the parallel naming that document prohibits.
class Store
  CONFIG_PATH = Rails.root.join("config/store.yml")

  class << self
    def name
      fetch("name")
    end

    def tagline
      fetch("tagline")
    end

    def support_email
      fetch("support_email")
    end

    def privacy_email
      fetch("privacy_email")
    end

    def press_email
      fetch("press_email")
    end

    def legal_entity
      fetch("legal_entity")
    end

    # Absolute base URL with no trailing slash, so callers can interpolate paths
    # without producing a double slash.
    def url
      ENV["STORE_URL"].presence || fetch("url").to_s.chomp("/")
    end

    # The version of the privacy policy that consent records refer to. Bumping
    # it in config/store.yml is how a consent given under an older text stays
    # distinguishable from one given under the current one.
    def policy_version
      fetch("privacy_policy_version")
    end

    def host
      URI.parse(url).host
    end

    def title_for(page_title)
      if page_title.blank?
        "#{name} - #{tagline}"
      else
        "#{page_title} | #{name}"
      end
    end

    def config
      @config ||= Rails.application.config_for(:store).deep_symbolize_keys
    end

    private
      def fetch(key)
        ENV["STORE_#{key.to_s.upcase}"].presence || config.fetch(key.to_sym)
      end
  end
end

# Brand identity, read from config/brand.yml.
#
# Everything that needs the brand name, tagline, contact address, or canonical
# URL reads it from here rather than hardcoding a string. That is what makes
# renaming the brand a one-line change in config/brand.yml rather than a find
# and replace across views, mailers, and structured data.
#
# Environment variables override the file so that one build can serve staging
# and production without a code change.
class Brand
  CONFIG_PATH = Rails.root.join("config/brand.yml")

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

    # Absolute base URL, with no trailing slash, so callers can interpolate
    # paths without producing a double slash.
    def url
      ENV["BRAND_URL"].presence || fetch("url").to_s.chomp("/")
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
      @config ||= Rails.application.config_for(:brand).deep_symbolize_keys
    end

    private
      def fetch(key)
        ENV["BRAND_#{key.to_s.upcase}"].presence || config.fetch(key.to_sym)
      end
  end
end

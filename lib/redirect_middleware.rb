# Slug changes, handled before routing.
#
# A redirect record exists because a URL was published and then changed. The
# middleware answers those paths with their new destination instead of a 404,
# which is what keeps an old link, an old sitemap entry or somebody's bookmark
# working.
#
# Lookups are cached: this runs before every request, and a redirect that costs
# a database round trip on each page view would be a tax on the whole site to
# serve a handful of retired URLs.
class RedirectMiddleware
  # Plain seconds rather than 1.hour: this file is loaded from config/application.rb,
  # before ActiveSupport's duration extensions are available.
  CACHE_TTL = 3600

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    redirect = lookup(request.path)

    if redirect.nil? || redirect[:to_path] == request.path
      @app.call(env)
    else
      [ redirect[:status_code], { "Location" => redirect[:to_path], "Content-Type" => "text/html; charset=utf-8" }, [ "Moved" ] ]
    end
  end

  private
    def lookup(path)
      Rails.cache.fetch("redirect:#{path}", expires_in: CACHE_TTL) do
        record = Redirect.resolve(path)
        record && { to_path: record.to_path, status_code: record.status_code }
      end
    end
end

module ApplicationHelper
  # Path for a static page by slug. Pages are routed through an explicit
  # allowlist rather than a catch-all, so this maps a slug to its named route.
  def page_path(slug)
    public_send(:"page_#{slug.to_s.tr('-', '_')}_path")
  end

  # Formats an integer number of minor units as a price.
  # Money is always an integer count of cents, never a float.
  def price(cents, currency: "USD")
    return tag.span("Free", class: "text-muted") if cents.nil?

    symbol = { "USD" => "$", "EUR" => "€", "GBP" => "£", "INR" => "₹" }.fetch(currency, "")
    whole, fraction = format("%.2f", cents / 100.0).split(".")

    tag.span(class: "tnum") do
      safe_join([
        tag.span(symbol, class: "text-muted"),
        whole,
        tag.span(".#{fraction}", class: "text-muted")
      ])
    end
  end
end

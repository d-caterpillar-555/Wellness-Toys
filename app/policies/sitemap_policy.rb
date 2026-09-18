# The sitemap lists what is published for anyone to read, so it is readable by
# anyone. What it excludes is the part that matters: nothing under /account,
# /cart, /checkout, /orders or /admin appears in it.
class SitemapPolicy < ApplicationPolicy
  def show?
    true
  end
end

class PagesController < ApplicationController
  # How many products the front page shows. Eight fills the catalogue ledger on
  # the institute front page without turning it into a catalogue page.
  FEATURED_LIMIT = 8

  # The library head on the front page: enough to show the shape of the
  # publishing, not the whole catalogue of writing.
  LIBRARY_LIMIT = 5

  def home
    authorize :page, :home?
    @register = Category.kept.with_catalogue_count.ordered
    @featured = policy_scope(Product).with_catalogue.newest_first.limit(FEATURED_LIMIT)
    @library = Article.published.kept.with_reading_list.recent_first.limit(LIBRARY_LIMIT)
  end

  def show
    @page = Page.find_by_slug!(params[:slug])
    authorize @page
  end
end

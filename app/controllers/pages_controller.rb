class PagesController < ApplicationController
  # How many products the home page shows. Four fills the register row without
  # turning the front page into a catalogue page.
  FEATURED_LIMIT = 8

  def home
    authorize :page, :home?
    @register = Category.kept.with_catalogue_count.ordered
    @featured = policy_scope(Product).with_catalogue.newest_first.limit(FEATURED_LIMIT)
  end

  def show
    @page = Page.find_by_slug!(params[:slug])
    authorize @page
  end
end

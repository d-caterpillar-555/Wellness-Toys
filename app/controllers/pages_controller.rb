class PagesController < ApplicationController
  def home
    authorize :page, :home?
  end

  def show
    @page = Page.find_by_slug!(params[:slug])
    authorize @page
  end
end

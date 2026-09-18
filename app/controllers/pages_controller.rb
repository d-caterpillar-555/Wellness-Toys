class PagesController < ApplicationController
  def home
  end

  def show
    @page = Page.find_by_slug!(params[:slug])
  end
end

module Worlds
  # folio: the whole shop as one continuous document.
  #
  # Every address in this world is an anchor on this one page, so the page is
  # loaded whole and makes no further requests: the catalogue, the library, the
  # standards and the contact all arrive together. The print view is the same
  # document with the furniture removed.
  class FolioController < BaseController
    world "folio"

    def index
      @departments = departments
      @products = catalogue
      @by_department = @products.group_by { |product| product.primary_category&.id }
      @unfiled = @by_department[nil] || []
      @reading = library(limit: 12)
      @standards = page_for("standards")
      @shipping = page_for("shipping")
    end

    def print
      index
      render :print
    end
  end
end

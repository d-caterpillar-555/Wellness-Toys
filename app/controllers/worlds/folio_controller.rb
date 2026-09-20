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
      load_document(plates: true)
    end

    def print
      load_document(plates: false)
      render :print
    end

    private

    # The whole document, loaded for the template that will print it: the index
    # shows the plates and the makers, the print view is text only, so it asks
    # for neither. An association a page never touches is a query nobody uses.
    def load_document(plates:)
      @departments = departments
      @products = catalogue.includes(:categories, :variants)
      @products = @products.includes(:brand, :cover_image_attachment) if plates
      @by_department = @products.group_by { |product| product.primary_category&.id }
      @unfiled = @by_department[nil] || []
      @reading = library(limit: 12).includes(:author)
      @reading = @reading.includes(:primary_topic) if plates
      @standards = page_for("standards")
      @shipping = page_for("shipping")
    end
  end
end

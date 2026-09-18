module Worlds
  # figure: the shop as a figure study.
  #
  # The home page is a choreography: a drawn figure moves through five poses as
  # the page scrolls, and each pose carries a chapter of the shop's argument.
  # The figure is drawn in the browser from a small skeleton (worlds/figure.js),
  # so the poses interpolate rather than snap, and a reader with reduced motion
  # gets one composed pose instead of a performance.
  class FigureController < BaseController
    world "figure"

    POSES = %w[stand reach fold rest open].freeze

    def index
      @pieces = catalogue.limit(6)
      @reading = library(limit: 4)
      @poses = POSES
    end

    def pieces
      @pieces = catalogue
      @departments = departments
    end

    def piece
      @product = catalogue.find_by!(slug: params[:slug])
      @variants = @product.variants.select(&:active?)
      @related = catalogue.where.not(id: @product.id).limit(3)
    end
  end
end

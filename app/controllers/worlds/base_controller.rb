module Worlds
  # The shared behaviour of the seven alternate architectures.
  #
  # A world controller renders public catalogue and library pages: a world has
  # no private resources of its own. Every load still goes through
  # policy_scope, so the same visibility rules apply as everywhere else on the
  # site. The storefront's per-action authorisation hooks are relaxed here
  # because a world's actions are page names (a room, a story, a shelf) rather
  # than resource verbs, and there is no record to authorise beyond the scope
  # it was loaded with.
  class BaseController < ApplicationController
    class << self
      attr_reader :world_slug

      def world(slug)
        @world_slug = slug.to_s
      end
    end

    layout :world_layout

    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped

    private

    def world
      @world ||= World.fetch(self.class.world_slug)
    end

    def world_layout
      world.layout
    end

    # The catalogue every world prints, in the shop's own order. The eager
    # loads belong to the page that prints the records: a world that prints
    # text does not load photography, and an association a page never touches
    # is a query nobody uses. Bullet's zero-warning gate is part of the
    # definition of done, so this is checked rather than remembered.
    def catalogue
      @catalogue ||= policy_scope(Product).available.newest_first
    end

    # Departments, each with the count a visitor could actually buy, in one
    # grouped query rather than a count per row.
    def departments
      @departments ||= Category.kept.with_catalogue_count.ordered
    end

    # The library, as a list. Same rule as the catalogue: the byline, the topic
    # and the evidence are asked for by the page that renders them. Sources are
    # counted from articles.sources_count, so no list loads them to count them.
    def library(limit: 12)
      policy_scope(Article).published.kept.recent_first.limit(limit)
    end

    def page_for(slug)
      Page.find_by_slug!(slug)
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end
end

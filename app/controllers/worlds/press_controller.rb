module Worlds
  # press: the shop as a newspaper.
  #
  # A paper that reviews what it sells. The front page is a real front page -
  # a masthead with an edition line, a lead, columns, a figures panel and
  # notices - and the catalogue is set as the paper's review section rather
  # than as a grid of cards. There is no motion anywhere in this world: print
  # does not animate.
  class PressController < BaseController
    world "press"

    def index
      @objects = catalogue
      @departments = departments
      @lead = library(limit: 1).first
      @features = library(limit: 6)
      @reviewed = @objects.limit(4)
      @counts = { objects: @objects.size, departments: @departments.length, pieces: library(limit: 100).size }
    end

    def reviews
      @objects = catalogue
      @departments = departments
      @counts = { objects: @objects.size, departments: @departments.length, pieces: library(limit: 100).size }
    end

    def issue
      @features = library(limit: 12)
      @departments = departments
      @counts = { objects: catalogue.size, departments: @departments.length, pieces: @features.size }
    end

    def story
      @topic = policy_scope(Topic).find_by!(slug: params[:topic_slug])
      @article = policy_scope(Article).published.kept.with_evidence.find_by!(slug: params[:slug])
      @related = library(limit: 4)
      @counts = { objects: catalogue.size, departments: departments.length, pieces: @related.size }
    end

    def notices
      @pages = Page::ROUTED_SLUGS.filter_map { |slug| page_for(slug) }
      @objects = catalogue.limit(6)
      @counts = { objects: catalogue.size, departments: departments.length, pieces: @pages.size }
    end
  end
end

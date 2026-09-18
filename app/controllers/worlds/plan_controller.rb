module Worlds
  # plan: the shop as a building.
  #
  # Departments are rooms on a floor plan and you navigate by walking into
  # them. The plan is drawn from the same records as everything else - a room
  # is a category, an object is a product - so nothing here can drift from the
  # catalogue. /plan/register is the plain ruled index, for anyone who would
  # rather not walk.
  class PlanController < BaseController
    world "plan"

    # The building: a corridor with three rooms above it and three below, in a
    # 1000x600 plan. Rooms are assigned to departments in their own order, so a
    # shop with four departments gets a building with four rooms and two empty
    # ones rather than a broken plan.
    ROOMS = [
      { x: 40, y: 40, w: 300, h: 220 },
      { x: 360, y: 40, w: 300, h: 220 },
      { x: 680, y: 40, w: 280, h: 220 },
      { x: 40, y: 350, w: 300, h: 210 },
      { x: 360, y: 350, w: 300, h: 210 },
      { x: 680, y: 350, w: 280, h: 210 }
    ].freeze

    def index
      building
      @objects = catalogue
    end

    def register
      @departments = departments
      @objects = catalogue
    end

    def room
      building
      @category = policy_scope(Category).kept.find_by!(slug: params[:slug])
      @objects = catalogue.for_category(@category.slug)
      @room = ROOMS[@departments.index(@category) || 0] || ROOMS.first
    end

    def object
      @departments = departments
      @product = catalogue.find_by!(slug: params[:slug])
      @variants = @product.variants.select(&:active?)
      @category = @product.primary_category
      @related = catalogue.for_category(@category&.slug).where.not(id: @product.id).limit(3)
    end

    private

    # Departments, assigned to rooms in the order the shop keeps them. Both the
    # plan and a room page draw the same building, so it is built in one place.
    def building
      @departments = departments
      @rooms = @departments.zip(ROOMS).map do |category, room|
        { category: category, room: room }
      end
      @empty_rooms = ROOMS.drop(@rooms.size)
    end
  end
end

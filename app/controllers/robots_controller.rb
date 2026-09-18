# What crawlers may fetch.
#
# The disallowed paths are the ones that carry a session, a cart, an order or an
# account. None of that belongs in an index, and the site never puts an
# identifier in a URL either way: orders are reached by token, not by number.
#
# The AI-crawler policy is deliberately left at the default (allowed). Blocking
# training crawlers is a decision with a tradeoff either way, and it has not
# been taken.
class RobotsController < ApplicationController
  def show
    authorize :robots, :show?
  end
end

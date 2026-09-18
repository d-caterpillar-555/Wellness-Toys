# robots.txt is a public instruction to crawlers, so it is readable by anyone.
# The rule it expresses (keep crawlers out of accounts, carts, checkouts and the
# console) is the part worth a policy method.
class RobotsPolicy < ApplicationPolicy
  def show?
    true
  end
end

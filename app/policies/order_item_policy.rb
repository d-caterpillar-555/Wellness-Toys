# An order line is a snapshot of what was bought, at the price it was bought at.
# Nothing edits it, including the console: a receipt that can be rewritten is not
# a receipt. It is readable by staff and by the owning customer through
# OrderPolicy.
class OrderItemPolicy < ApplicationPolicy
end

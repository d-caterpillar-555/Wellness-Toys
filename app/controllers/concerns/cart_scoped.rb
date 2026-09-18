# Resolves the cart for the current request.
#
# A cart belongs to exactly one owner: a signed-in customer or an anonymous
# guest token. This concern never guesses which, and it stores only the scalar
# guest token in the session, never a cart id, so a cart can never be adopted
# by changing a session value to a number someone else might also hold.
module CartScoped
  extend ActiveSupport::Concern

  GUEST_TOKEN_KEY = :guest_cart_token

  included do
    helper_method :current_cart, :cart_item_count
  end

  # Memoised for the request: a page that reads the count twice does not create
  # the cart twice.
  def current_cart
    @current_cart ||= resolve_cart
  end

  def cart_item_count
    current_cart.item_count
  end

  private
    def resolve_cart
      return signed_in_cart_for(current_user) if user_signed_in?

      guest_cart_for(session[GUEST_TOKEN_KEY] ||= SecureRandom.urlsafe_base64(24))
    end

    # Queried through the scope rather than reached through `user.cart`: the
    # association would fire a second query on a record Warden already loaded,
    # and the scope says the same thing in one place both callers can use.
    def signed_in_cart_for(user)
      merge_guest_cart(Cart.for_user(user).first || Cart.create!(user: user))
    end

    def guest_cart_for(token)
      Cart.for_guest(token).first || Cart.create!(guest_token: token)
    end

    # A visitor who signs in keeps the cart they filled as a guest: the guest
    # cart folds into the account cart, then the token leaves the session so
    # the merge happens once rather than on every later request.
    def merge_guest_cart(cart)
      token = session[GUEST_TOKEN_KEY]
      return cart if token.blank?

      guest = Cart.for_guest(token).first
      guest.merge_into!(cart) if guest && guest.id != cart.id
      session.delete(GUEST_TOKEN_KEY)
      cart.reload
    end
end

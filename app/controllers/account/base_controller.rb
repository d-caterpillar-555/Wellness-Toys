# Everything under /account belongs to the signed-in person. Requiring
# authentication here is the first of two locks: each action also authorises the
# record it touches, or scopes the lookup to the account, so no route can read
# another account's rows by changing an id.
class Account::BaseController < ApplicationController
  before_action :authenticate_user!
end

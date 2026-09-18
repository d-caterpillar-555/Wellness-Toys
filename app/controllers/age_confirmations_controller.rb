# The age gate is a soft gate: it records an acknowledgement in the visitor's
# own session and lets browsing continue. Blocking at the edge would stop the
# catalogue being publicly readable and indexable, which the plan deliberately
# chose not to do.
#
# The answer is not a consent record. It is a statement about the person
# browsing, not permission for the store to do something with their data, and
# recording it as a consent row would blur two different things.
class AgeConfirmationsController < ApplicationController
  def create
    authorize :age_confirmation, :create?
    session[:age_confirmed_at] = Time.current.to_i
    redirect_back fallback_location: root_path
  end
end

class Account::DashboardController < Account::BaseController
  RECENT_ORDERS = 3

  def show
    authorize current_user
    @orders = policy_scope(Order).recent_first.limit(RECENT_ORDERS)
    @addresses = policy_scope(Address).recent_first
    @open_requests = policy_scope(DataRequest).open_requests.recent_first
  end
end

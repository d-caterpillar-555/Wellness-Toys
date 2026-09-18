# A privacy request is a person asking for a copy of their data, or for it to be
# erased. The record is theirs; the work happens out of band, in the admin
# console, which is why a request is created here and completed elsewhere.
class Account::DataRequestsController < Account::BaseController
  def index
    @requests = policy_scope(DataRequest).recent_first
  end

  def new
    @request = current_user.data_requests.new(kind: permitted_kind)
    authorize @request
  end

  def create
    @request = current_user.data_requests.new(request_params)
    authorize @request
    if @request.save
      DataExportJob.perform_later(@request) if @request.kind == "export"
      redirect_to account_data_requests_path, notice: t("account.data_requests.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def permitted_kind
      DataRequest::KINDS.include?(params[:kind]) ? params[:kind] : "export"
    end

    def request_params
      params.require(:data_request).permit(:kind)
    end
end

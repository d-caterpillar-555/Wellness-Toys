class Account::AddressesController < Account::BaseController
  def index
    @addresses = policy_scope(Address).recent_first
  end

  def new
    @address = current_user.addresses.new
    authorize @address
  end

  def create
    @address = current_user.addresses.new(address_params)
    authorize @address
    if @address.save
      apply_defaults(@address)
      redirect_to account_addresses_path, notice: t("account.addresses.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @address = address
    authorize @address
  end

  def update
    @address = address
    authorize @address
    if @address.update(address_params)
      apply_defaults(@address)
      redirect_to account_addresses_path, notice: t("account.addresses.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize address, :destroy?
    address.discard
    redirect_to account_addresses_path, notice: t("account.addresses.removed"), status: :see_other
  end

  private
    # Scoped to the account, so an id belonging to somebody else is a 404
    # rather than a policy refusal that would confirm the row exists.
    def address
      @address ||= policy_scope(Address).find(params[:id])
    end

    def address_params
      params.require(:address).permit(
        :label, :recipient, :line1, :line2, :city, :region, :postal_code, :country_code
      )
    end

    # The two defaults are mutually exclusive, and each is unique per account,
    # so they go through the model's own methods rather than a column write
    # that would collide with the partial unique indexes.
    def apply_defaults(address)
      address.make_default_shipping! if params.dig(:address, :default_shipping) == "1"
      address.make_default_billing! if params.dig(:address, :default_billing) == "1"
    end
end

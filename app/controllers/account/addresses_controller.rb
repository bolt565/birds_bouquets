class Account::AddressesController < ApplicationController
  before_action :require_login!
  before_action :set_address, only: [:edit, :update, :destroy, :set_default]

  def index
    @addresses = current_user.addresses.default_first
  end

  def new
    @address = Address.new
  end

  def create
    @address = current_user.addresses.build(address_params)
    @address.default = current_user.addresses.empty?

    if @address.save
      flash[:notice] = "Address added."
      redirect_to account_addresses_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @address.update(address_params)
      flash[:notice] = "Address updated."
      redirect_to account_addresses_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @address.destroy
      flash[:notice] = "Address removed."
    else
      flash[:alert] = @address.errors.full_messages.join(", ")
    end
    redirect_to account_addresses_path
  end

  def set_default
    @address.update!(default: true)
    flash[:notice] = "Default address updated."
    redirect_to account_addresses_path
  end

  private

  def set_address
    @address = current_user.addresses.find(params[:id])
  end

  def address_params
    params.require(:address).permit(:name, :line1, :line2, :city, :state, :zip, :country, :phone, :label, :default)
  end
end

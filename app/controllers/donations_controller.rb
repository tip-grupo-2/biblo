class DonationsController < ApplicationController
  before_action :authenticate_user!
  def show
    @donation = Donation.find(params[:id])
  end
end

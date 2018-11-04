class DonationsController < ApplicationController
  def show
    @donation = Donation.find(params[:id])
  end
end

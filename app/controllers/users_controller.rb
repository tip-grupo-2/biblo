class UsersController < ApplicationController
  def show
    @users = User.all
    @hash = Gmaps4rails.build_markers(@users) do |user, marker|
    marker.lat user.latitude
    marker.lng user.longitude
    end
  end

   def edit
     @user = User.find(params[:id])
   end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to @user
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:id, :name, :address, :avatar)
  end
end
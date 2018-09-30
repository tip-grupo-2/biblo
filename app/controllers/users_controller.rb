class UsersController < ApplicationController
 def show
  @users = User.all
  @hash = Gmaps4rails.build_markers(@users) do |user, marker|
   marker.lat user.latitude
   marker.lng user.longitude
  end
 end
end
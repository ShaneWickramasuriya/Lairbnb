class LairsController < ApplicationController
  before_action :set_lair, only: [:show, :edit, :update, :destroy]

  def index
    @lairs = Lair.all
  end

  def show
    # boolean @owner to know whether the current user is the owner of the lair
    @user = @lair.user
    @owner = @user == current_user ? true : false
    @booking = Booking.new
    @user_bookings = []
    @user_bookings = find_user_bookings
  end

  def new
    @lair = Lair.new
  end

  def create
    @lair = Lair.new(lair_params)
    @lair.user = current_user # store the user or user id??
    @lair.is_hero_lair = current_user.is_hero # set lair to same boolean as creator hero status
    if @lair.save
      redirect_to lair_path(@lair)
    else
      render :new
    end
  end

  def edit; end

  def update
    if @lair.update(lair_params)
      redirect_to lair_path(@lair)
    else
      render :edit
    end
  end

  def destroy
    @lair.destroy
    redirect_to user_path(current_user)
  end

  def search
    if params[:search].empty?
      @lairs = Lair.all
    else
      lairs = Lair.arel_table
      lairs_by_title = Lair.where(lairs[:title].matches("%#{params[:search]}%"))
      lairs_by_location = Lair.where(lairs[:location].matches("%#{params[:search]}%"))
      @lairs = (lairs_by_title | lairs_by_location) - (lairs_by_title & lairs_by_location)
    end
  end

  private

  def lair_params
    params.require(:lair).permit(:title, :location, :description, :price_per_night, photos: [])
  end

  def set_lair
    @lair = Lair.find(params[:id])
  end

  def find_user_bookings
    bookings = []
    current_user.bookings.each do |booking|
      bookings << booking if booking == Booking.find(params[:id])
    end
    bookings
  end
end

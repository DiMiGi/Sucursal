class StaffsController < ApplicationController

  before_action :authenticate_staff!
  #before_action :set_staff, only: [:update, :destroy]

  def pundit_user
    current_staff
  end

  def new
    authorize Staff
  end

  def create
    staff = Staff.new(staff_params)
    authorize @staff

    if staff.save
      render json: staff, status: :created
    else
      render json: staff.errors, status: :unprocessable_entity
    end
  end


  private
  def set_staff
    @staff = Staff.find(params[:id])
  end

  def staff_params
    params.fetch(:staff).permit(:names, :first_name, :second_name, :branch_office, :position)
  end

end

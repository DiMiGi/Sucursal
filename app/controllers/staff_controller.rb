class StaffController < ApplicationController

  before_action :authenticate_staff!
  #before_action :set_staff, only: [:update, :destroy]

  def pundit_user
    current_staff
  end

  def new
    authorize Staff

    if current_staff.manager?
      @branch_office = current_staff.branch_office.full_address
    end

  end

  def create

    newStaff = Staff.new(staff_params)
    authorize newStaff

    if newStaff.save
      render json: newStaff, status: :created
    else
      render json: newStaff.errors, status: :unprocessable_entity
    end
  end


  private
  def set_staff
    @staff = Staff.find(params[:id])
  end

  def staff_params
    params.fetch(:staff).permit(:names, :password, :password_confirmation, :first_surname, :second_surname, :branch_office_id, :position, :email)
  end

end

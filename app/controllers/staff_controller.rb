class StaffController < ApplicationController

  before_action :authenticate_staff!
  before_action :set_staff, only: [:update_time_blocks]

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

    attributes = staff_params
    attributes['password'] = params[:password]
    attributes['password_confirmation'] = params[:password_confirmation]

    newStaff = Staff.new(attributes)
    authorize newStaff

    if newStaff.save
      render json: newStaff, status: :created
    else
      render json: newStaff.errors, status: :unprocessable_entity
    end
  end


  def update_time_blocks

    unless StaffPolicy.new(current_staff, @staff).update_time_blocks?
      raise Pundit::NotAuthorizedError
    end


    time_blocks = params[:time_blocks]

    ActiveRecord::Base.transaction do
      TimeBlock.where(executive_id: @staff.id).delete_all
      time_blocks.each do |block|
        @staff.time_blocks << TimeBlock.new(
          :weekday => block[:weekday],
          :hour => block[:hour],
          :minutes => block[:minutes])
      end
    end

    render :json => {}, :status => :ok
  end


  private
  def set_staff
    @staff = Staff.find(params[:id])
  end

  def staff_params
    params.fetch(:staff).permit(:names, :first_surname, :second_surname, :branch_office_id, :position, :email)
  end

end

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
    attributes[:password] = params[:staff][:password]
    attributes[:password_confirmation] = params[:staff][:password_confirmation]

    # Para que la ID de la sucursal sea la misma que el jefe de sucursal que esta creando el usuario
    if current_staff.manager?
      attributes[:branch_office_id] = current_staff.branch_office_id
    end

    newStaff = Staff.new(attributes)

    unless StaffPolicy.new(current_staff, newStaff).create?
      raise Pundit::NotAuthorizedError
    end

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

  def staff_save_perfil
    was_saved = true
    if params[:assignment_show_until_days]
      current_staff.assignment_show_until_days = params[:assignment_show_until_days].to_i
      was_saved = was_saved && current_staff.save
    end

    if was_saved
      flash[:notice] = "Perfil saved"
      redirect_to "/staff/#{current_staff.id}"
    else
      flash[:notice] = "Perfil not saved"
      redirect_to "/staff/#{current_staff.id}"
    end
  end

  def show_appointments
    if !current_staff.executive?
      raise Pundit::NotAuthorizedError
    end

    @appointments = current_staff.appointments.where(:time => DateTime.current.beginning_of_day..DateTime.current.end_of_day.advance(:days => params[:days].to_i))

  end

  def new_reassign_appointments_to_executive
    if current_staff.executive?
      raise Pundit::NotAuthorizedError
    end

    # Encontrar ejecutios de la misma sucursal

    if(current_staff.supervisor?)
      @ejecutivos = Executive.all.where(:branch_office => current_staff.branch_office,:attention_type => current_staff.attention_type)
    else
      @ejecutivos = Executive.all.where(:branch_office => current_staff.branch_office)
    end

  end

  def reassign_appointments_to_executive
    if current_staff.executive?
      raise Pundit::NotAuthorizedError
    end

    executive_to_take_appointments_out = Executive.find(params[:executives_appointment_taked_away].to_i)
    executive_to_put_appointments_in = Executive.find(params[:executives_appointment_putted_in].to_i)

    if executive_to_take_appointments_out.reassign_appointments_to(executive_to_put_appointments_in)
      flash[:notice] = "Appointments successfully assigned"
      redirect_to "/staff/appointments/reassing"
    else
      flash[:notice] = "Appointments wasn't assigned"
      redirect_to "/staff/appointments/reassing"
    end

  end

  def show

  end

  def edit
    @staff = Staff.find(params[:id])
  end

  def select
    @staffs = Staff.all
  end

  def update
    staff = Staff.find(params[:id])
    nombre = params[:names]
    papellido = params[:first_surname]
    sapellido = params[:second_surname]
    email = params[:email]
    staff.update(names: nombre)
    staff.update(first_surname: papellido)
    staff.update(second_surname: sapellido)
    staff.update(email: email)
    redirect_to action: "select"
  end

  private
  def set_staff
    @staff = Staff.find(params[:id])
  end

  def staff_params
    params.fetch(:staff).permit(:names, :first_surname, :second_surname, :branch_office_id, :type, :email)
  end

end

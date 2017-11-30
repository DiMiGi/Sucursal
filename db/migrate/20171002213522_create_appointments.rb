class CreateAppointments < ActiveRecord::Migration[5.1]
  def change
    create_table :appointments do |t|

      t.integer :status, null: false, default: 0
      t.belongs_to :staff, index: true
      t.belongs_to :staff, :staff_took_appointment, index: false
      t.belongs_to :staff, :staff_owner_appointment, index: false
      t.datetime :time, null: false
      t.datetime :finished_time

      # No tiene llave foranea, por el hecho de que se encuentra en otra
      # base de datos. Esto se puede cambiar dependiendo de como se lleve
      # a cabo la integracion con el resto del sistema en Movistar.
      t.string :client_id, null: false
      t.string :client_names, null: false
      t.string :client_email, null: true


      # El modelo de BD tiene un "branch_office", pero eso se puede
      # obtener a traves del personal, ya que el personal es un ejecutivo y
      # el tiene la ID de la sucursal.

      # El tipo de atencion tambien se sabe por medio del personal.

      t.timestamps
    end
    #add_reference :appointments, :staff_took_appointment, index: false
  end
end

class CreateAppointments < ActiveRecord::Migration[5.1]
  def change
    create_table :appointments do |t|

      t.belongs_to :staff, index: true
      t.date :day, null: false

      # Falta la asociacion con el cliente.
      # El modelo de BD tiene un "branch_office", pero eso se puede
      # obtener a traves del personal, ya que el personal es un ejecutivo y
      # el tiene la ID de la sucursal.

      # El tipo de atencion tambien se sabe por medio del personal.

      t.timestamps
    end
  end
end

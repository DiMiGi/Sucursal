class CreateAppointments < ActiveRecord::Migration[5.1]
  def change
    create_table :appointments do |t|

      t.belongs_to :staff, index: true
      t.datetime :time, null: false

      # No tiene llave foranea, por el hecho de que se encuentra en otra
      # base de datos. Esto se puede cambiar dependiendo de como se lleve
      # a cabo la integracion con el resto del sistema en Movistar.
      t.integer :client_id


      # El modelo de BD tiene un "branch_office", pero eso se puede
      # obtener a traves del personal, ya que el personal es un ejecutivo y
      # el tiene la ID de la sucursal.

      # El tipo de atencion tambien se sabe por medio del personal.

      t.timestamps
    end
  end
end

class CreateDaysOff < ActiveRecord::Migration[5.1]
  def change
    create_table :days_off do |t|

      # Para que un dia feriado pueda pertenecer a una sucursal completa
      t.belongs_to :branch_office, index: true

      # Para que un personal (ejecutivo) pueda tener un dia ausente
      t.belongs_to :staff, index: true

      # Y ambas son opcionales (pueden ser NULL en la base de datos, para que
      # cuando ambas son NULL, significa que son dias ausentes globales, es decir,
      # para todas las sucursales, y todos los ejecutivos)

      t.date :day, null: false

      t.timestamps
    end
  end
end

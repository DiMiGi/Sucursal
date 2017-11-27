class Report < ApplicationRecord

  def self.to_csv
  	puts "entre a la funcion"
  	attributes = %w{status}
  	puts attributes
    CSV.generate(headers: true) do |csv|
      puts "AHHHHHHHHHHHHH"
      csv << column_names
      puts csv
      Appointment.all.each do |cita|
        csv << cita.attributes.values_at(*column_names)
        puts cita.attributes.values_at(*column_names)
      end
    end
  end


end

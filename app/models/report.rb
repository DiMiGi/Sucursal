class Report < ApplicationRecord

  def self.to_csv
  	puts "entre a la funcion"
  	attributes = %w{status}
  	puts attributes
    CSV.generate(headers: true) do |csv|
      puts "AHHHHHHHHHHHHH"
      csv << attributes
      Appointment.all.each do |cita|
        csv << cita.attributes.values
      end
    end
  end


end

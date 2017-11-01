class Report < ApplicationRecord

  def self.to_csv
    CSV.generate do |csv|
      csv << column_names
  end


end

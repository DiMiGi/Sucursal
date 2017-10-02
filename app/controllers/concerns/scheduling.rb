module Scheduling
  extend ActiveSupport::Concern

  included do
  end


  # Esta funcion recibe el dia, sucursal, y tipo de atencion
  # y obtiene todos los bloques libres que hay para poder realizar
  # reuniones en ese dia, en esa sucursal, y con ese tipo de atencion.
  def getFreeBlocks(day:, branch_office:, attention_type:)




  end


end

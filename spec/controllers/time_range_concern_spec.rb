require 'rails_helper'

RSpec.describe AppointmentsController, type: :ctrl do

  describe "concern time_range (operaciones de rangos de tiempo)" do

    let(:ctrl) { AppointmentsController.new }

    it "prueba la funcion para redondear hacia arriba" do
      expect(ctrl.ceil 0, 7).to eq 0
      expect(ctrl.ceil 3, 7).to eq 7
      expect(ctrl.ceil 6, 7).to eq 7
      expect(ctrl.ceil 7, 7).to eq 7
      expect(ctrl.ceil 8, 7).to eq 14
      expect(ctrl.ceil 10, 7).to eq 14
      expect(ctrl.ceil 14, 7).to eq 14
      expect(ctrl.ceil 15, 7).to eq 21
      expect(ctrl.ceil 1015, 15).to eq 1020
    end

    it "comprime bloques horarios disponibles y los retorna como rangos" do
      expect(ctrl.compress(discretization: 15, times: [480, 495, 510, 525, 555, 570, 585], length: 15)).to eq [[480, 540], [555, 600]]
      expect(ctrl.compress(discretization: 15, times: [810, 910, 925, 940, 955, 970, 985, 1000, 1015], length: 15)).to eq [[810, 825], [900, 1035]]
      expect(ctrl.compress(discretization: 15, times: [810, 910, 925, 940, 955, 970, 985, 1000, 1015], length: 15)).to eq [[810, 825], [900, 1035]]
      expect(ctrl.compress(discretization: 15, times: [810, 910], length: 15)).to eq [[810, 825], [900, 930]]
      expect(ctrl.compress(discretization: 15, times: [810, 825, 840], length: 15)).to eq [[810, 855]]
      expect(ctrl.compress(discretization: 15, times: [812], length: 15)).to eq [[810, 840]]
      expect(ctrl.compress(discretization: 15, times: [824], length: 15)).to eq [[810, 840]]
      expect(ctrl.compress(discretization: 15, times: [2, 812], length: 15)).to eq [[0, 30], [810, 840]]
      expect(ctrl.compress(discretization: 15, times: [810], length: 15)).to eq [[810, 825]]
      expect(ctrl.compress(discretization: 15, times: [810, 825], length: 15)).to eq [[810, 840]]
      expect(ctrl.compress(discretization: 15, times: [810, 840, 855], length: 15)).to eq [[810, 825], [840, 870]]
      expect(ctrl.compress(discretization: 15, times: [810, 825, 840, 855, 870, 885, 1000], length: 15)).to eq [[810, 900], [990, 1020]]
      expect(ctrl.compress(discretization: 15, times: [800, 840, 855], length: 15)).to eq [[795, 825], [840, 870]]
    end

    it "comprime los horarios de las citas y lo retorna como rangos" do
      expect(ctrl.compress(discretization: 5, times: [], length: 25)).to eq []
      expect(ctrl.compress(discretization: 5, times: [800, 912, 924, 947], length: 3)).to eq [[800, 805], [910, 915], [920, 930], [945, 950]]
      expect(ctrl.compress(discretization: 10, times: [810, 813, 816, 822], length: 3)).to eq [[810, 830]]
      expect(ctrl.compress(discretization: 15, times: [850, 870], length: 20)).to eq [[840, 900]]
      expect(ctrl.compress(discretization: 5, times: [850, 860, 885], length: 20)).to eq [[850, 880], [885, 905]]
      expect(ctrl.compress(discretization: 10, times: [810, 811, 815, 817], length: 10)).to eq [[810, 830]]
      expect(ctrl.compress(discretization: 3, times: [800, 801, 805, 807], length: 5)).to eq [[798, 813]]
      expect(ctrl.compress(discretization: 7, times: [800, 807, 817, 818], length: 5)).to eq [[798, 826]]
      expect(ctrl.compress(discretization: 13, times: [802, 809, 817, 829], length: 6)).to eq [[793, 845]]
      expect(ctrl.compress(discretization: 1, times: [0, 6, 6, 12], length: 6)).to eq [[0, 18]]
      expect(ctrl.compress(discretization: 2, times: [0, 6, 6, 12], length: 6)).to eq [[0, 18]]
      expect(ctrl.compress(discretization: 3, times: [0, 6, 6, 12], length: 6)).to eq [[0, 18]]
      expect(ctrl.compress(discretization: 4, times: [0, 6, 6, 12], length: 6)).to eq [[0, 20]]
      expect(ctrl.compress(discretization: 5, times: [0, 6, 6, 13], length: 6)).to eq [[0, 20]]
      expect(ctrl.compress(discretization: 15, times: [490, 510, 510, 530], length: 10)).to eq [[480, 540]]
      expect(ctrl.compress(discretization: 10, times: [490, 510, 510, 530], length: 10)).to eq [[490, 500], [510, 520], [530, 540]]
      expect(ctrl.compress(discretization: 5, times: [535], length: 25)).to eq [[535, 560]]
      expect(ctrl.compress(discretization: 7, times: [535], length: 25)).to eq [[532, 560]]
      expect(ctrl.compress(discretization: 7, times: [534], length: 25)).to eq [[532, 560]]
      expect(ctrl.compress(discretization: 7, times: [533], length: 25)).to eq [[532, 560]]
      expect(ctrl.compress(discretization: 1, times: [533], length: 25)).to eq [[533, 558]]
    end


    it "determina los rangos de horarios que el ejecutivo tiene libre" do

      # Tiene los bloques 8:00, 8:15, 8:30 y una hora a las 8:15 de 15 minutos
      expect(ctrl.get_available_ranges(duration: 5, time_blocks: [[480, 525]], appointments: [[495, 510]])).to eq [[480, 495], [510, 525]]

      # Tiene los bloques 8:00, 8:15, 8:30 y una hora a las 8:15 de 5 minutos
      expect(ctrl.get_available_ranges(duration: 5, time_blocks: [[480, 525]], appointments: [[495, 500]])).to eq [[480, 495], [500, 525]]

      # Tiene los bloques 8:00, 8:15, 8:45 y una hora a las 8:10 de 40 minutos (esto no deberia pasar en la practica
      # ya que eso implica tener una cita en donde no tiene horarios disponibles)
      expect(ctrl.get_available_ranges(duration: 5, time_blocks: [[480, 510], [525, 540]], appointments: [[490, 530]])).to eq [[480, 490], [530, 540]]

      # Lo mismo que lo anterior, pero ahora la duracion de la atencion es mas larga, y ninguno
      # de los bloques resultantes es lo suficientemente largo como para que haya una reunion ahi.
      expect(ctrl.get_available_ranges(duration: 15, time_blocks: [[480, 510], [525, 540]], appointments: [[490, 530]])).to eq []

      # Lo mismo que lo anterior, pero ahora existe un bloque donde puede haber una
      # reunion ya que tiene otro bloque disponible.
      expect(ctrl.get_available_ranges(duration: 15, time_blocks: [[480, 510], [525, 555]], appointments: [[490, 530]])).to eq [[530, 555]]

      # Tiene todos los bloques desde las 8:00 hasta las 15:00 (el 915 se debe a 15*60 + los 15 minutos que dura el bloque).
      expect(ctrl.get_available_ranges(duration: 15, time_blocks: [[480, 915]], appointments: [[490, 530], [530, 530]])).to eq [[530, 915]]
      expect(ctrl.get_available_ranges(duration: 15, time_blocks: [[480, 915]], appointments: [[490, 530], [530, 600]])).to eq [[600, 915]]
      expect(ctrl.get_available_ranges(duration: 15, time_blocks: [[480, 915]], appointments: [[490, 530], [580, 600]])).to eq [[530, 580], [600, 915]]
      expect(ctrl.get_available_ranges(duration: 15, time_blocks: [[480, 915]], appointments: [[900, 915]])).to eq [[480, 900]]
      expect(ctrl.get_available_ranges(duration: 15, time_blocks: [[480, 915]], appointments: [[900, 1000]])).to eq [[480, 900]]
      expect(ctrl.get_available_ranges(duration: 15, time_blocks: [[480, 915]], appointments: [[480, 500]])).to eq [[500, 915]]
      expect(ctrl.get_available_ranges(duration: 15, time_blocks: [[480, 915]], appointments: [[200, 480]])).to eq [[480, 915]]
      expect(ctrl.get_available_ranges(duration: 15, time_blocks: [[480, 915]], appointments: [[200, 490]])).to eq [[490, 915]]
      expect(ctrl.get_available_ranges(duration: 15, time_blocks: [[480, 915]], appointments: [[500, 510], [600, 610], [620, 630], [700, 710]])).to eq [[480, 500], [510, 600], [630, 700], [710, 915]]

      # Otros
      # Duracion muy larga y hace que ningun bloque resultante sea suficiente para una atencion, por lo tanto retorna vacio.
      expect(ctrl.get_available_ranges(time_blocks: [[795, 810], [825, 855], [885, 915], [960, 975], [1050, 1065]], appointments: [[840, 860], [880, 940]], duration: 20)).to eq []

      expect(ctrl.get_available_ranges(time_blocks: [[480, 540], [555, 600]], appointments: [], duration: 50)).to eq [[480, 540]]
      expect(ctrl.get_available_ranges(time_blocks: [[510, 525], [540, 555]], appointments: [], duration: 50)).to eq []
      expect(ctrl.get_available_ranges(time_blocks: [[0, 20], [30, 50]], appointments: [[15, 35]], duration: 5)).to eq [[0, 15], [35, 50]]
      expect(ctrl.get_available_ranges(time_blocks: [[480, 540], [555, 600]], appointments: [[535, 560]], duration: 25)).to eq [[480, 535], [560, 600]]
    end


  end

end

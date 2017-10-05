require 'rails_helper'

RSpec.describe AppointmentsController, type: :controller do

  describe "concern time_range (operaciones de conjuntos y rangos de tiempo)" do

    let(:controller) { AppointmentsController.new }

    it "prueba la funcion para redondear hacia arriba" do
      expect(controller.ceil 0, 7).to eq 0
      expect(controller.ceil 3, 7).to eq 7
      expect(controller.ceil 6, 7).to eq 7
      expect(controller.ceil 7, 7).to eq 7
      expect(controller.ceil 8, 7).to eq 14
      expect(controller.ceil 10, 7).to eq 14
      expect(controller.ceil 14, 7).to eq 14
      expect(controller.ceil 15, 7).to eq 21
      expect(controller.ceil 1015, 15).to eq 1020
    end

    it "comprime bloques horarios disponibles y los retorna como rangos" do
      expect(controller.compress(times: [810, 910, 925, 940, 955, 970, 985, 1000, 1015], length: 15)).to eq [[810, 825], [900, 1035]]
      expect(controller.compress(times: [810, 910], length: 15)).to eq [[810, 825], [900, 930]]
      expect(controller.compress(times: [810, 825, 840], length: 15)).to eq [[810, 855]]
      expect(controller.compress(times: [812], length: 15)).to eq [[810, 840]]
      expect(controller.compress(times: [824], length: 15)).to eq [[810, 840]]
      expect(controller.compress(times: [2, 812], length: 15)).to eq [[0, 30], [810, 840]]
      expect(controller.compress(times: [810], length: 15)).to eq [[810, 825]]
      expect(controller.compress(times: [810, 825], length: 15)).to eq [[810, 840]]
      expect(controller.compress(times: [810, 840, 855], length: 15)).to eq [[810, 825], [840, 870]]
      expect(controller.compress(times: [810, 825, 840, 855, 870, 885, 1000], length: 15)).to eq [[810, 900], [990, 1020]]
      expect(controller.compress(times: [800, 840, 855], length: 15)).to eq [[795, 825], [840, 870]]
    end

    it "comprime los horarios de las citas y lo retorna como rangos" do
      expect(controller.compress(times: [800, 912, 924, 947], length: 3)).to eq [[798, 804], [912, 915], [924, 927], [945, 951]]
      expect(controller.compress(times: [810, 813, 816, 822], length: 3)).to eq [[810, 819], [822, 825]]
      expect(controller.compress(times: [850, 870], length: 20)).to eq [[840, 900]]
      expect(controller.compress(times: [850, 860, 885], length: 20)).to eq [[840, 920]]
      expect(controller.compress(times: [810, 811, 815, 817], length: 10)).to eq [[810, 830]]
      expect(controller.compress(times: [800, 801, 805, 807], length: 5)).to eq [[800, 815]]
      expect(controller.compress(times: [800, 807, 817, 818], length: 5)).to eq [[800, 825]]
      expect(controller.compress(times: [802, 809, 817, 829], length: 6)).to eq [[798, 840]]
      expect(controller.compress(times: [0, 6, 6, 12], length: 6)).to eq [[0, 18]]
      expect(controller.compress(times: [0, 6, 6, 13], length: 6)).to eq [[0, 24]]
      expect(controller.compress(times: [490, 510, 510, 530], length: 10)).to eq [[490, 500], [510, 520], [530, 540]]
    end

    it "une dos conjuntos correctamente" do
      expect(controller.union([[0, 5]], [[10, 20]])).to eq [[0, 5], [10, 20]]
      expect(controller.union([[0, 5]], [[0, 20]])).to eq [[0, 20]]
      expect(controller.union([[0, 5]], [[]])).to eq [[0, 5]]
      expect(controller.union([[]], [[10, 20]])).to eq [[10, 20]]
      expect(controller.union([[]], [[]])).to eq []
      expect(controller.union([[0, 5], [5, 10]], [[]])).to eq [[0, 10]]
      expect(controller.union([[0, 5], [5, 10]], [[4, 6]])).to eq [[0, 10]]
      expect(controller.union([[10, 100], [200, 400], [500, 500]], [[110, 150]])).to eq [[10, 100], [110, 150], [200, 400], [500, 500]]
      expect(controller.union([[10, 100], [200, 400], [500, 500]], [[500, 600]])).to eq [[10, 100], [200, 400], [500, 600]]
      expect(controller.union([[10, 100], [200, 400], [500, 500]], [[480, 550]])).to eq [[10, 100], [200, 400], [480, 550]]
      expect(controller.union([[0, 5], [6, 10], [15, 20]], [[4, 8], [9, 14]])).to eq [[0, 14], [15, 20]]
      expect(controller.union([[0, 5], [6, 10], [15, 20]], [[4, 8], [1000, 1000]])).to eq [[0, 10], [15, 20], [1000, 1000]]
      expect(controller.union([[1, 3], [7, 9], [15, 15]], [[4, 6], [10, 15]])).to eq [[1, 3], [4, 6], [7, 9], [10, 15]]
      expect(controller.union([], [])).to eq []
      expect(controller.union([[0, 0], [4, 4]], [])).to eq [[0, 0], [4, 4]]
      expect(controller.union([], [[0, 0], [4, 4]])).to eq [[0, 0], [4, 4]]
      expect(controller.union([[5, 7]], [4, 89])).to eq [[4, 89]]
      expect(controller.union([[1, 3], [7, 9]], [3, 7])).to eq [[1, 9]]
      expect(controller.union([[1, 3], [7, 9]], [[3, 7], [123,567]])).to eq [[1, 9], [123, 567]]
      expect(controller.union([[1, 3], [3, 5]], [[2, 4], [4, 8]])).to eq [[1, 8]]
      expect(controller.union([[1, 5], [6, 8]], [[8, 10], [11, 15]])).to eq [[1, 5], [6, 10], [11, 15]]
    end

    it "determina los rangos de horarios que el ejecutivo tiene libre" do

      # Tiene los bloques 8:00, 8:15, 8:30 y una hora a las 8:15 de 15 minutos
      expect(controller.get_available_ranges(duration: 5, time_blocks: [[480, 525]], appointments: [[495, 510]])).to eq [[480, 495], [510, 525]]

      # Tiene los bloques 8:00, 8:15, 8:30 y una hora a las 8:15 de 5 minutos
      expect(controller.get_available_ranges(duration: 5, time_blocks: [[480, 525]], appointments: [[495, 500]])).to eq [[480, 495], [500, 525]]

      # Tiene los bloques 8:00, 8:15, 8:45 y una hora a las 8:10 de 40 minutos (esto no deberia pasar en la practica
      # ya que eso implica tener una cita en donde no tiene horarios disponibles)
      expect(controller.get_available_ranges(duration: 5, time_blocks: [[480, 510], [525, 540]], appointments: [[490, 530]])).to eq [[480, 490], [530, 540]]

      # Lo mismo que lo anterior, pero ahora la duracion de la atencion es mas larga, y ninguno
      # de los bloques resultantes es lo suficientemente largo como para que haya una reunion ahi.
      expect(controller.get_available_ranges(duration: 15, time_blocks: [[480, 510], [525, 540]], appointments: [[490, 530]])).to eq []

      # Lo mismo que lo anterior, pero ahora existe un bloque donde puede haber una
      # reunion ya que tiene otro bloque disponible.
      expect(controller.get_available_ranges(duration: 15, time_blocks: [[480, 510], [525, 555]], appointments: [[490, 530]])).to eq [[530, 555]]

      # Tiene todos los bloques desde las 8:00 hasta las 15:00 (el 915 se debe a 15*60 + los 15 minutos que dura el bloque).
      expect(controller.get_available_ranges(duration: 15, time_blocks: [[480, 915]], appointments: [[490, 530], [530, 530]])).to eq [[530, 915]]
      expect(controller.get_available_ranges(duration: 15, time_blocks: [[480, 915]], appointments: [[490, 530], [530, 600]])).to eq [[600, 915]]
      expect(controller.get_available_ranges(duration: 15, time_blocks: [[480, 915]], appointments: [[490, 530], [580, 600]])).to eq [[530, 580], [600, 915]]
      expect(controller.get_available_ranges(duration: 15, time_blocks: [[480, 915]], appointments: [[900, 915]])).to eq [[480, 900]]
      expect(controller.get_available_ranges(duration: 15, time_blocks: [[480, 915]], appointments: [[900, 1000]])).to eq [[480, 900]]
      expect(controller.get_available_ranges(duration: 15, time_blocks: [[480, 915]], appointments: [[480, 500]])).to eq [[500, 915]]
      expect(controller.get_available_ranges(duration: 15, time_blocks: [[480, 915]], appointments: [[200, 480]])).to eq [[480, 915]]
      expect(controller.get_available_ranges(duration: 15, time_blocks: [[480, 915]], appointments: [[200, 490]])).to eq [[490, 915]]
      expect(controller.get_available_ranges(duration: 15, time_blocks: [[480, 915]], appointments: [[500, 510], [600, 610], [620, 630], [700, 710]])).to eq [[480, 500], [510, 600], [630, 700], [710, 915]]

    end


  end

end

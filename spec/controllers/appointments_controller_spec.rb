require 'rails_helper'

RSpec.describe AppointmentsController, type: :controller do

  describe "algoritmos y sub algoritmos (sub rutinas) para planificacion" do

    let(:controller) { AppointmentsController.new }

    # Preparar una base de datos de prueba
    before(:all) do
      @office = FactoryGirl.create(:branch_office, id: 1007, minute_discretization: 5)
      @attention = FactoryGirl.create(:attention_type, id: 1007)

      e1 = FactoryGirl.create(:executive, id: 2001, branch_office: @office, attention_type: @attention)
      e2 = FactoryGirl.create(:executive, id: 2002, branch_office: @office, attention_type: @attention)
      e3 = FactoryGirl.create(:executive, id: 2003, branch_office: @office, attention_type: @attention)
      e4 = FactoryGirl.create(:executive, id: 2004, branch_office: @office, attention_type: @attention)

      FactoryGirl.create(:global_day_off, day: Date.new(2017, 10, 1))
      FactoryGirl.create(:global_day_off, day: Date.new(2017, 10, 3))
      FactoryGirl.create(:executive_day_off, executive: e1, day: Date.new(2017, 10, 2))
      FactoryGirl.create(:executive_day_off, executive: e1, day: Date.new(2017, 10, 3))
      FactoryGirl.create(:executive_day_off, executive: e1, day: Date.new(2017, 10, 4))
      FactoryGirl.create(:executive_day_off, executive: e2, day: Date.new(2017, 10, 1))
      FactoryGirl.create(:executive_day_off, executive: e2, day: Date.new(2017, 10, 3))
      FactoryGirl.create(:executive_day_off, executive: e2, day: Date.new(2017, 10, 5))
      FactoryGirl.create(:branch_office_day_off, branch_office: @office, day: Date.new(2017, 10, 4))

      @office.duration_estimations << DurationEstimation.new(duration: 17, attention_type: @attention)

      e1.time_blocks << FactoryGirl.build(:time_block, :monday, hour: 13, minutes: 0)
      e1.time_blocks << FactoryGirl.build(:time_block, :monday, hour: 13, minutes: 30)
      e1.time_blocks << FactoryGirl.build(:time_block, :monday, hour: 14, minutes: 0)
      e1.time_blocks << FactoryGirl.build(:time_block, :monday, hour: 14, minutes: 30)
      e1.time_blocks << FactoryGirl.build(:time_block, :monday, hour: 14, minutes: 45)
      e1.time_blocks << FactoryGirl.build(:time_block, :thursday, hour: 20, minutes: 30)
      e2.time_blocks << FactoryGirl.build(:time_block, :monday, hour: 13, minutes: 15)
      e2.time_blocks << FactoryGirl.build(:time_block, :monday, hour: 13, minutes: 45)
      e2.time_blocks << FactoryGirl.build(:time_block, :monday, hour: 17, minutes: 30)
      e2.time_blocks << FactoryGirl.build(:time_block, :monday, hour: 15, minutes: 0)
      e2.time_blocks << FactoryGirl.build(:time_block, :monday, hour: 14, minutes: 0)
      e2.time_blocks << FactoryGirl.build(:time_block, :monday, hour: 16, minutes: 0)
      e2.time_blocks << FactoryGirl.build(:time_block, :monday, hour: 14, minutes: 45)
      e1.save
      e2.save
      e3.save
      e4.save

      @app1 = FactoryGirl.create(:appointment, executive: e1, time: DateTime.new(2017, 10, 2, 13, 31, 0))
      @app2 = FactoryGirl.create(:appointment, executive: e1, time: DateTime.new(2017, 10, 2, 14, 46, 0))
      @app3 = FactoryGirl.create(:appointment, executive: e2, time: DateTime.new(2017, 10, 2, 14, 1, 0))
      @app4 = FactoryGirl.create(:appointment, executive: e2, time: DateTime.new(2017, 10, 2, 15, 11, 0))
      @app5 = FactoryGirl.create(:appointment, executive: e2, time: DateTime.new(2017, 10, 2, 14, 49, 0))
    end

    it "prueba la funcion para redondear hacia arriba" do
      expect(controller.ceil 0, 7).to eq 0
      expect(controller.ceil 3, 7).to eq 7
      expect(controller.ceil 6, 7).to eq 7
      expect(controller.ceil 7, 7).to eq 7
      expect(controller.ceil 8, 7).to eq 14
      expect(controller.ceil 10, 7).to eq 14
      expect(controller.ceil 14, 7).to eq 14
      expect(controller.ceil 15, 7).to eq 21
    end

    it "obtiene el indice del dia sin errores" do
      expect(controller.day_index Date.new(2017, 9, 30)).to eq 5
      expect(controller.day_index Date.new(2017, 10, 1)).to eq 6
      expect(controller.day_index Date.new(2017, 10, 2)).to eq 0
      expect(controller.day_index Date.new(2017, 10, 3)).to eq 1
      expect(controller.day_index Date.new(2017, 10, 4)).to eq 2
      expect(controller.day_index Date.new(2017, 10, 5)).to eq 3
      expect(controller.day_index Date.new(2017, 10, 6)).to eq 4
      expect(controller.day_index Date.new(2017, 10, 7)).to eq 5
      expect(controller.day_index Date.new(2017, 10, 8)).to eq 6
      expect(controller.day_index Date.new(2017, 10, 9)).to eq 0
    end

    it "comprime bloques horarios disponibles y los retorna como rangos" do
      expect(controller.compress(times: [800, 900, 915, 930, 945, 960, 975, 990, 1005], length: 15)).to eq [[800, 815], [900, 1020]]
      expect(controller.compress(times: [800, 900], length: 15)).to eq [[800, 815], [900, 915]]
      expect(controller.compress(times: [800, 815, 830], length: 15)).to eq [[800, 845]]
      expect(controller.compress(times: [800], length: 15)).to eq [[800, 815]]
      expect(controller.compress(times: [800, 815], length: 15)).to eq [[800, 830]]
      expect(controller.compress(times: [800, 830, 845], length: 15)).to eq [[800, 815], [830, 860]]
      expect(controller.compress(times: [800, 815, 830, 845, 860, 875, 890], length: 15)).to eq [[800, 905]]
    end

    it "comprime los horarios de las citas y lo retorna como rangos" do
      # para que estos tests funcionen, hay que hacer que los tiempos partan en un multiplo de 60
      # onda no puede ser 800.
      #expect(controller.compress(times: [800, 900, 915, 930], length: 3)).to eq [[800, 803], [900, 903], [915, 918], [930, 933]]
      #expect(controller.compress(times: [800, 803, 806, 812], length: 3)).to eq [[800, 809], [812, 815]]
      expect(controller.compress(times: [840, 850, 875], length: 20)).to eq [[840, 900]]
      #expect(controller.compress(times: [800, 801, 805, 807], length: 10)).to eq [[800, 820]]
      #expect(controller.compress(times: [800, 801, 805, 807], length: 5)).to eq [[800, 810]]
      #expect(controller.compress(times: [800, 807, 817, 818], length: 5)).to eq [[800, 805], [805, 810], [815]]
    end

    describe "algoritmo que entrega un mapa con todos los datos necesarios para poder ejecutar algoritmos de planificacion" do

      it "entrega un mapa con todos los datos necesarios para poder ejecutar algoritmos de planificacion" do
        result = controller.get_data(day: Date.new(2017, 10, 2), branch_office_id: @office.id, attention_type_id: @attention.id)
        expect(result.class).to eq Hash
        expect(result).to have_key :discretization
        expect(result[:discretization]).to eq 5
        expect(result).to have_key :attention_duration
        expect(result[:attention_duration]).to eq 20
        expect(result).to have_key :executives
        expect(result[:executives]).to_not have_key 2001 # Tiene un dia feriado (o dia libre, etc)
        expect(result[:executives]).to have_key 2002
        expect(result[:executives]).to_not have_key 2003 # Es borrado porque no tiene bloques horarios
        expect(result[:executives]).to_not have_key 2004 # Es borrado porque no tiene bloques horarios
        expect(result[:executives][2002]).to have_key :time_blocks
        expect(result[:executives][2002]).to have_key :appointments
        expect(result[:executives][2002][:time_blocks].length).to eq 7
      end

      it "entrega las citas del/los ejecutivos en una lista ordenada por fecha" do
        result = controller.get_data(day: Date.new(2017, 10, 2), branch_office_id: @office.id, attention_type_id: @attention.id)
        a3 = (14 * 60) + 0
        a5 = (14 * 60) + 45
        a4 = (15 * 60) + 10
        expect(result[:executives][2002][:appointments]).to eq [a3, a5, a4]
      end

      it "entrega los bloques disponibles del/los ejecutivos en una lista ordenada" do
        result = controller.get_data(day: Date.new(2017, 10, 2), branch_office_id: @office.id, attention_type_id: @attention.id)
        list = [(13*60)+15, (13*60)+45, (17*60)+30, 15*60, 14*60, 16*60, (14*60)+45]
        list.sort!
        expect(result[:executives][2002][:time_blocks]).to eq list
      end

      it "retorna vacio cuando hay un feriado a nivel global" do
        result = controller.get_data(day: Date.new(2017, 10, 1), branch_office_id: @office.id, attention_type_id: @attention.id)
        expect(result).to eq({})
      end

      it "retorna vacio cuando hay un feriado a nivel de sucursal" do
        result = controller.get_data(day: Date.new(2017, 10, 4), branch_office_id: @office.id, attention_type_id: @attention.id)
        expect(result).to eq({})
      end

      it "retorna los valores correctos probando con otro dia" do
        result = controller.get_data(day: Date.new(2017, 10, 5), branch_office_id: @office.id, attention_type_id: @attention.id)
        expect(result[:executives]).to have_key 2001
        expect(result[:executives][2001]).to have_key :time_blocks
        expect(result[:executives][2001]).to have_key :appointments
        expect(result[:executives][2001][:appointments]).to eq []
        expect(result[:executives][2001][:time_blocks].length).to eq 1
      end

      it "retorna vacio si no hay ningun ejecutivo disponible (incluso si no hay ningun feriado)" do
        result = controller.get_data(day: Date.new(2017, 10, 8), branch_office_id: @office.id, attention_type_id: @attention.id)
        expect(result).to eq({})
      end

    end

  end

end

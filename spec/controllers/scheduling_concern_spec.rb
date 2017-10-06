require 'rails_helper'

RSpec.describe AppointmentsController, type: :ctrl do

  describe "algoritmos y sub algoritmos (sub rutinas) para planificacion" do

    let(:ctrl) { AppointmentsController.new }

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
      e3.time_blocks << FactoryGirl.build(:time_block, :monday, hour: 14, minutes: 45)
      e3.time_blocks << FactoryGirl.build(:time_block, :tuesday, hour: 14, minutes: 45)
      e3.time_blocks << FactoryGirl.build(:time_block, :wednesday, hour: 14, minutes: 45)
      e3.time_blocks << FactoryGirl.build(:time_block, :thursday, hour: 14, minutes: 45)
      e3.time_blocks << FactoryGirl.build(:time_block, :friday, hour: 14, minutes: 45)
      e4.time_blocks << FactoryGirl.build(:time_block, :tuesday, hour: 14, minutes: 45)
      e4.time_blocks << FactoryGirl.build(:time_block, :wednesday, hour: 14, minutes: 45)
      e4.time_blocks << FactoryGirl.build(:time_block, :thursday, hour: 14, minutes: 45)
      e4.time_blocks << FactoryGirl.build(:time_block, :friday, hour: 14, minutes: 45)
      e4.time_blocks << FactoryGirl.build(:time_block, :saturday, hour: 14, minutes: 45)
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

    it "obtiene el indice del dia sin errores" do
      expect(ctrl.day_index Date.new(2017, 9, 30)).to eq 5
      expect(ctrl.day_index Date.new(2017, 10, 1)).to eq 6
      expect(ctrl.day_index Date.new(2017, 10, 2)).to eq 0
      expect(ctrl.day_index Date.new(2017, 10, 3)).to eq 1
      expect(ctrl.day_index Date.new(2017, 10, 4)).to eq 2
      expect(ctrl.day_index Date.new(2017, 10, 5)).to eq 3
      expect(ctrl.day_index Date.new(2017, 10, 6)).to eq 4
      expect(ctrl.day_index Date.new(2017, 10, 7)).to eq 5
      expect(ctrl.day_index Date.new(2017, 10, 8)).to eq 6
      expect(ctrl.day_index Date.new(2017, 10, 9)).to eq 0
    end


    describe "algoritmo que entrega todos los puntos del tiempo donde se puede agendar una hora (pruebas de caja negra)" do

      it "obtiene las horas correctamente" do

        Dir.foreach(Rails.root.join("spec", "test_data", "scheduling")) do |filename|
          GlobalDayOff.destroy_all
          if filename.end_with?(".json")

            json_file = File.read(Rails.root.join("spec", "test_data", "scheduling", filename))
            data = ActiveSupport::JSON.decode(json_file)

            attention_types = []
            branch_offices = []
            executives = []
            data["branch_offices"].each do |discretization|
              branch_offices << FactoryGirl.create(:branch_office, minute_discretization: discretization)
            end

            data["attention_types"].times { attention_types << FactoryGirl.create(:attention_type) }

            data["executives"].each do |executive|
              o = executive["branch_office"]
              a = executive["attention_type"]
              new_executive = FactoryGirl.create(:executive, branch_office: branch_offices[o], attention_type: attention_types[a])
              executives << new_executive

              executive["appointments"].each do |appointment|
                split = appointment.split ' '
                yyyy = split[0].to_i
                mm = split[1].to_i
                dd = split[2].to_i
                hh = split[3].to_i
                min = split[4].to_i
                FactoryGirl.create(:appointment, executive: new_executive, time: DateTime.new(yyyy, mm, dd, hh, min))
              end
            end

            data["duration_estimations"].each do |estimation|
              b = estimation["branch_office"]
              a = estimation["attention_type"]
              d = estimation["duration"]
              FactoryGirl.create(:duration_estimation, duration: d, branch_office: branch_offices[b], attention_type: attention_types[a])
            end

            data["global_days_off"].each do |day|
              FactoryGirl.create(:global_day_off, day: Date.new(day["yyyy"], day["mm"], day["dd"]))
            end

            data["executive_days_off"].each do |day|
              executive = executives[day["executive"]]
              date = Date.new(day["yyyy"], day["mm"], day["dd"])
              FactoryGirl.create(:executive_day_off, executive: executive, day: date)
            end

            data["branch_office_days_off"].each do |day|
              branch_office = branch_offices[day["branch_office"]]
              date = Date.new(day["yyyy"], day["mm"], day["dd"])
              FactoryGirl.create(:branch_office_day_off, branch_office: branch_office, day: date)
            end

            data["time_blocks"].each do |time_block|
              executive = executives[time_block["executive"]]
              weekday = time_block["weekday"]
              hour = time_block["hour"]
              minutes = time_block["minutes"]
              executive.time_blocks << FactoryGirl.build(:time_block, weekday: weekday, hour: hour, minutes: minutes)
              executive.save!
            end

            data["queries"].each do |query|
              type = query["type"]

              # Hay que hacer todo este codigo porque el retorno de la funcion en el concern
              # tiene un formato distinto al que tiene el JSON de prueba. No se pueden hacer iguales porque
              # en el JSON desconozco cuales son las IDs de lo que retorna la funcion. Por esa razon transformo
              # las IDs para que sean las que realmente estan en la base de datos. Ademas se comprueban
              # que los bloques de tiempo sean los mismos.
              #
              # En caso de existir problemas entendiendo esto, realmente lo que importa es entender el formato
              # de los JSON de prueba. Este codigo solo sirve para comprobar que el resultado sea igual a lo que
              # arroja la funcion.
              if type == "assert_all"
                attention_type_id = attention_types[query["attention_type"]].id
                branch_office_id = branch_offices[query["branch_office"]].id
                correct_result = query["result"]
                split = query["day"].split ' '
                day = Date.new(split[0].to_i, split[1].to_i, split[2].to_i)
                result = ctrl.get_all_available_appointments(day: day, branch_office_id: branch_office_id, attention_type_id: attention_type_id)
                expect(result.keys.length).to eq correct_result.length
                correct_result.each do |t|
                  expect(result).to have_key t["time"].to_i
                  t["ids"].each_with_index do |item, i|
                    t["ids"][i] = executives[t["ids"][i]].id
                  end
                  expect(t["ids"]).to eq result[t["time"].to_i]
                end
              end

              if type == "assert_executive"
                branch_office_id = branch_offices[query["branch_office"]].id
                executive_id = executives[query["executive"]].id
                attention_type_id = executives[query["executive"]].attention_type_id
                correct_result = query["result"]
                split = query["day"].split ' '
                day = Date.new(split[0].to_i, split[1].to_i, split[2].to_i)

                data = ctrl.get_data(day: day, branch_office_id: branch_office_id, attention_type_id: attention_type_id)

                expect(correct_result).to eq [] if !data.has_key? :executives
                expect(correct_result).to eq [] if !data[:executives].has_key? executive_id

                time_blocks = data[:executives][executive_id][:time_blocks]
                appointments = data[:executives][executive_id][:appointments]
                duration = data[:attention_duration]

                result = ctrl.get_executive_available_appointments(time_blocks: time_blocks, appointments: appointments, duration: duration)
                expect(result).to eq correct_result
              end


              if type == "add_appointment"
                executive = executives[query["executive"]]
                split = query["time"].split ' '
                time = DateTime.new(split[0].to_i, split[1].to_i, split[2].to_i, split[3].to_i, split[4].to_i)
                FactoryGirl.create(:appointment, executive: executive, time: time)
              end

              if type == "change_discretization"
                value = query["value"]
                b = query["branch_office"]
                branch_offices[b].minute_discretization = value
                branch_offices[b].save!
              end

              if type == "change_estimation"
                value = query["value"]
                b = query["branch_office"]
                a = query["attention_type"]
                # Por ahora no supe como hacer esta consulta con ORM y/o FactoryGirl
                if !value.nil?
                  ActiveRecord::Base.connection.execute("update duration_estimations set duration = #{value} where branch_office_id = #{branch_offices[b].id} AND attention_type_id = #{attention_types[a].id}")
                else
                  ActiveRecord::Base.connection.execute("delete from duration_estimations where branch_office_id = #{branch_offices[b].id} AND attention_type_id = #{attention_types[a].id}")
                end
              end

              if type == "add_time_block"
                weekday = query["weekday"]
                hour = query["hour"]
                minutes = query["minutes"]
                e = query["executive"]
                executives[e].time_blocks << FactoryGirl.build(:time_block, weekday: weekday, hour: hour, minutes: minutes)
              end
            end




          end
        end
      end
    end


    describe "algoritmo que entrega un mapa con todos los datos necesarios para poder ejecutar algoritmos de planificacion" do

      it "entrega un mapa con todos los datos necesarios para poder ejecutar algoritmos de planificacion" do
        result = ctrl.get_data(day: Date.new(2017, 10, 2), branch_office_id: @office.id, attention_type_id: @attention.id)
        expect(result.class).to eq Hash
        expect(result).to have_key :discretization
        expect(result[:discretization]).to eq 5
        expect(result).to have_key :attention_duration
        expect(result[:attention_duration]).to eq 20
        expect(result).to have_key :executives
        expect(result[:executives]).to_not have_key 2001 # Tiene un dia feriado (o dia libre, etc)
        expect(result[:executives]).to have_key 2002
        expect(result[:executives]).to_not have_key 2004 # Es borrado porque no tiene bloques horarios
        expect(result[:executives][2002]).to have_key :time_blocks
        expect(result[:executives][2002]).to have_key :appointments
        expect(result[:executives][2002][:time_blocks].length).to eq 7
      end

      it "entrega las citas del/los ejecutivos en una lista ordenada por fecha" do
        result = ctrl.get_data(day: Date.new(2017, 10, 2), branch_office_id: @office.id, attention_type_id: @attention.id)
        a3 = (14 * 60) + 0
        a5 = (14 * 60) + 45
        a4 = (15 * 60) + 10
        expect(result[:executives][2002][:appointments]).to eq [a3, a5, a4]
      end

      it "obtiene los ejecutivos que estan disponibles el dia escogido" do

        result = ctrl.get_data(day: Date.new(2017, 10, 2), branch_office_id: @office.id, attention_type_id: @attention.id)
        expect(result[:executives].keys).to eq [2002, 2003]

        result = ctrl.get_data(day: Date.new(2017, 10, 3), branch_office_id: @office.id, attention_type_id: @attention.id)
        expect(result).to eq({})

        result = ctrl.get_data(day: Date.new(2017, 10, 3), branch_office_id: @office.id, attention_type_id: @attention.id)
        expect(result).to eq({})

        result = ctrl.get_data(day: Date.new(2017, 10, 5), branch_office_id: @office.id, attention_type_id: @attention.id)
        expect(result[:executives].keys).to eq [2001, 2003, 2004]

        result = ctrl.get_data(day: Date.new(2017, 10, 6), branch_office_id: @office.id, attention_type_id: @attention.id)
        expect(result[:executives].keys).to eq [2003, 2004]

        result = ctrl.get_data(day: Date.new(2017, 10, 7), branch_office_id: @office.id, attention_type_id: @attention.id)
        expect(result[:executives].keys).to eq [2004]

      end



      it "entrega los bloques disponibles del/los ejecutivos en una lista ordenada" do
        result = ctrl.get_data(day: Date.new(2017, 10, 2), branch_office_id: @office.id, attention_type_id: @attention.id)
        list = [(13*60)+15, (13*60)+45, (17*60)+30, 15*60, 14*60, 16*60, (14*60)+45]
        list.sort!
        expect(result[:executives][2002][:time_blocks]).to eq list
      end

      it "retorna vacio cuando hay un feriado a nivel global" do
        result = ctrl.get_data(day: Date.new(2017, 10, 1), branch_office_id: @office.id, attention_type_id: @attention.id)
        expect(result).to eq({})
      end

      it "retorna vacio cuando hay un feriado a nivel de sucursal" do
        result = ctrl.get_data(day: Date.new(2017, 10, 4), branch_office_id: @office.id, attention_type_id: @attention.id)
        expect(result).to eq({})
      end

      it "retorna los valores correctos probando con otro dia" do
        result = ctrl.get_data(day: Date.new(2017, 10, 5), branch_office_id: @office.id, attention_type_id: @attention.id)
        expect(result[:executives]).to have_key 2001
        expect(result[:executives][2001]).to have_key :time_blocks
        expect(result[:executives][2001]).to have_key :appointments
        expect(result[:executives][2001][:appointments]).to eq []
        expect(result[:executives][2001][:time_blocks].length).to eq 1
      end

      it "retorna vacio si no hay ningun ejecutivo disponible (incluso si no hay ningun feriado)" do
        result = ctrl.get_data(day: Date.new(2017, 10, 8), branch_office_id: @office.id, attention_type_id: @attention.id)
        expect(result).to eq({})
      end

    end

  end

end

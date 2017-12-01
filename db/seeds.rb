AttentionType.create!(id: 1, name: 'Servicio técnico')
AttentionType.create!(id: 2, name: 'Atención comercial')
AttentionType.create!(id: 3, name: 'Recambio')
AttentionType.create!(id: 4, name: 'Accesorios')

Region.create!(name: 'Región de Tarapacá')
Region.create!(name: 'Región del Maule')
Region.create!(name: 'Región del Libertador General Bernardo O\'Higgins')
metropolitana = Region.create(name: 'Región Metropolitana de Santiago')

comunas_metropolitana = ['Cerrillos', 'Santiago', 'La Reina', 'Pudahuel', 'Cerro Navia', 'Las Condes',
'Quilicura', 'Conchalí', 'Lo Barnechea', 'Quinta Normal', 'El Bosque',
'Lo Espejo', 'Recoleta', 'Estación Central', 'Lo Prado', 'Renca',
'Huechuraba', 'Macul', 'San Miguel', 'Independencia', 'Maipú', 'San Joaquín',
'La Cisterna', 'Ñuñoa', 'San Ramón', 'La Florida', 'Pedro Aguirre Cerda',
'La Pintana', 'Peñalolén', 'Vitacura', 'La Granja', 'Providencia',
'Padre Hurtado', 'San Bernardo', 'Puente Alto', 'Pirque', 'San José de Maipo']

comunas_metropolitana.each do |comuna|
  metropolitana.comunas << Comuna.new(name: comuna)
end

metropolitana.save!

bo1 = BranchOffice.create!(id: 1, address: 'Av. Americo Vespucio 1501, Los Cerrillos', comuna_id: metropolitana.comunas[0].id, latitude: -33.517938, longitude: -70.717311)
bo2 = BranchOffice.create!(id: 2, address: 'Bellas Artes 1234', comuna_id: metropolitana.comunas[1].id, latitude: -33.436539, longitude: -70.644306)

ex1 = Executive.create!(branch_office: bo1, attention_type_id: 1, names: "juan andres", first_surname: "valdes", second_surname: "vasquez", email: 'juan@mail.com', password: '123123', password_confirmation: '123123')
ex2 = Executive.create!(branch_office: bo1, attention_type_id: 1, names: "juan jose", first_surname: "rios", second_surname: "rios", email: 'juan.jose@mail.com', password: '123123', password_confirmation: '123123')
Executive.create!(branch_office: bo1, attention_type_id: 2, names: "pedro pablo", first_surname: "silva", second_surname: "osorio", email: 'pedro@mail.com', password: '123123', password_confirmation: '123123')
Manager.create!(branch_office: bo2, names: "natalia belen", first_surname: "vilches", second_surname: "cespedes", email: 'natalia@mail.com', password: '123123', password_confirmation: '123123')
Manager.create!(branch_office: bo1, names: "juan carlos", first_surname: "bodoque", second_surname: "bodoque", email: 'jcarlos@mail.com', password: '123123', password_confirmation: '123123')
Supervisor.create!(branch_office: bo2, names: "pablo matias", first_surname: "Díaz de Valdés", second_surname: "pastene", email: 'pablo@mail.com', password: '123123', password_confirmation: '123123')
Supervisor.create!(branch_office: bo1, attention_type_id: 1, names: "richard", first_surname: "li", email: 'carlos@mail.com', password: '123123', password_confirmation: '123123')

Admin.create!(names: "rodrigo juan", first_surname: "martinez", second_surname: "un", email: 'admin@mail.com', password: '123123', password_confirmation: '123123')

DurationEstimation.create!(branch_office_id: 1, attention_type_id: 1, duration: 5)
DurationEstimation.create!(branch_office_id: 1, attention_type_id: 2, duration: 10)
DurationEstimation.create!(branch_office_id: 1, attention_type_id: 3, duration: 15)
DurationEstimation.create!(branch_office_id: 1, attention_type_id: 4, duration: 5)

DurationEstimation.create!(branch_office_id: 2, attention_type_id: 1, duration: 20)
DurationEstimation.create!(branch_office_id: 2, attention_type_id: 2, duration: 15)
DurationEstimation.create!(branch_office_id: 2, attention_type_id: 3, duration: 10)
DurationEstimation.create!(branch_office_id: 2, attention_type_id: 4, duration: 5)


for w in 0..4
  for h in 8..16
    ex1.time_blocks << TimeBlock.new(weekday: w, hour: h, minutes: 0)
    ex1.time_blocks << TimeBlock.new(weekday: w, hour: h, minutes: 15)
    ex1.time_blocks << TimeBlock.new(weekday: w, hour: h, minutes: 30)
    ex1.time_blocks << TimeBlock.new(weekday: w, hour: h, minutes: 45)
  end
end

for w in 0..4
  for h in 8..16
    ex2.time_blocks << TimeBlock.new(weekday: w, hour: h, minutes: 0)
    ex2.time_blocks << TimeBlock.new(weekday: w, hour: h, minutes: 15)
    ex2.time_blocks << TimeBlock.new(weekday: w, hour: h, minutes: 30)
    ex2.time_blocks << TimeBlock.new(weekday: w, hour: h, minutes: 45)
  end
end

ex1.save!
ex2.save!

Appointment.create!(executive: ex1,client_id: "1000-0",client_names: "Jorge Saavedra", client_email: "",time: Time.zone.local(2017, 12, 1, 14, 0))
Appointment.create!(executive: ex1,client_id: "1200-1",client_names: "Sonia Pereira", client_email: "",time: Time.zone.local(2017, 12, 1, 15, 0))
Appointment.create!(executive: ex1,client_id: "1300-k",client_names: "Jhon Schvaez", client_email: "",time: Time.zone.local(2017, 12, 4, 14, 0))
Appointment.create!(executive: ex2,client_id: "1000-2",client_names: "Jorge Sandoval", client_email: "",time: Time.zone.local(2017, 12, 2, 14, 0))
Appointment.create!(executive: ex2,client_id: "1100-3",client_names: "Pedro Rodriguez", client_email: "",time: Time.zone.local(2017, 12, 4, 14, 0))


a = BranchOffice.create!(:comuna => Comuna.find(26), :address => "Nueva Maria Angelica 6437", :latitude => -33.509240, :longitude => -70.526862)
DurationEstimation.create!(:branch_office => a, :attention_type => AttentionType.find(1), :duration => 13)
b = Executive.create!(:branch_office => a, attention_type_id: 1, names: "jose miguel", first_surname: "valdes", second_surname: "vasquez", email: 'josem@mail.com', password: '123123', password_confirmation: '123123')
for i in [0,1,2,3,4,5,6]
	for j in [8,9,10,11,12,13,14]
		for k in [0,15,30,45]
			b.time_blocks << TimeBlock.new(:weekday => i, :hour => j, :minutes => k)
			if(j == 14)
				break
			end
		end
	end
end

a.save!
b.save!

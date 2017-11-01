AttentionType.create!(id: 1, name: 'Servicio técnico')
AttentionType.create!(id: 2, name: 'Atención comercial')
AttentionType.create!(id: 3, name: 'Recambio')
AttentionType.create!(id: 4, name: 'Accesorios')

Region.create!(name: 'Región de Tarapacá')
Region.create!(name: 'Región del Maule')
ohiggins = Region.create!(name: 'Región del Libertador General Bernardo O\'Higgins')
metropolitana = Region.create(name: 'Región Metropolitana de Santiago')

comunas_hoggins = ['Rancagua', 'Machali', 'Graneros', 'San Francisco'];

comunas_metropolitana = ['Cerrillos', 'La Reina', 'Pudahuel', 'Cerro Navia', 'Las Condes',
'Quilicura', 'Conchalí', 'Lo Barnechea', 'Quinta Normal', 'El Bosque',
'Lo Espejo', 'Recoleta', 'Estación Central', 'Lo Prado', 'Renca',
'Huechuraba', 'Macul', 'San Miguel', 'Independencia', 'Maipú', 'San Joaquín',
'La Cisterna', 'Ñuñoa', 'San Ramón', 'La Florida', 'Pedro Aguirre Cerda',
'Santiago', 'La Pintana', 'Peñalolén', 'Vitacura', 'La Granja', 'Providencia',
'Padre Hurtado', 'San Bernardo', 'Puente Alto', 'Pirque', 'San José de Maipo']

comunas_metropolitana.each do |comuna|
  metropolitana.comunas << Comuna.new(name: comuna)
end

comunas_hoggins.each do |comuna|
  ohiggins.comunas << Comuna.new(name: comuna)
end

metropolitana.save!

bo1 = BranchOffice.create!(address: 'Calle Principal #123', comuna_id: metropolitana.comunas[3].id)
bo2 = BranchOffice.create!(address: 'Paseo Bulnes #456', comuna_id: metropolitana.comunas[6].id)
bo3 = BranchOffice.create!(address: 'Av. Providencia #789', comuna_id: metropolitana.comunas[10].id)
bo4 = BranchOffice.create!(address: 'Autopista Central #101', comuna_id: metropolitana.comunas[20].id)
bo5 = BranchOffice.create!(address: 'Avenida Alameda #777', comuna_id: metropolitana.comunas[20].id)

bo6 = BranchOffice.create!(address: 'Miguel Ramirez #123', comuna_id: ohiggins.comunas[0].id)
bo7 = BranchOffice.create!(address: 'Araucana #789', comuna_id: ohiggins.comunas[0].id)
bo8 = BranchOffice.create!(address: 'Carretera del Cobre #456', comuna_id: ohiggins.comunas[1].id)

ex1 = Executive.create!(branch_office: bo1, names: "juan andres", first_surname: "valdes", second_surname: "vasquez", email: 'juan@mail.com', password: '123123', password_confirmation: '123123')
ex2 = Executive.create!(branch_office: bo1, names: "juan jose", first_surname: "valdes", second_surname: "rios", email: 'juan.jose@mail.com', password: '123123', password_confirmation: '123123')
Executive.create!(branch_office: bo2, names: "pedro pablo", first_surname: "silva", second_surname: "osorio", email: 'pedro@mail.com', password: '123123', password_confirmation: '123123')
Manager.create!(branch_office: bo4, names: "natalia belen", first_surname: "vilches", second_surname: "cespedes", email: 'natalia@mail.com', password: '123123', password_confirmation: '123123')
Manager.create!(branch_office: bo1, names: "juan carlos", first_surname: "bodoque", second_surname: "bodoque", email: 'jcarlos@mail.com', password: '123123', password_confirmation: '123123')
Supervisor.create!(branch_office: bo3, names: "pablo matias", first_surname: "Díaz de Valdés", second_surname: "pastene", email: 'pablo@mail.com', password: '123123', password_confirmation: '123123')
Supervisor.create!(branch_office: bo1, names: "richard", first_surname: "li", email: 'carlos@mail.com', password: '123123', password_confirmation: '123123')

Admin.create!(names: "rodrigo juan", first_surname: "jong", second_surname: "un", email: 'admin@mail.com', password: '123123', password_confirmation: '123123')

Appointment.create!(executive: ex1,client_id: 1000,time: Time.zone.local(2018, 1, 1, 14, 0))
Appointment.create!(executive: ex1,client_id: 1200,time: Time.zone.local(2018, 1, 6, 14, 0))
Appointment.create!(executive: ex1,client_id: 1300,time: Time.zone.local(2018, 1, 7, 14, 0))
Appointment.create!(executive: ex2,client_id: 1000,time: Time.zone.local(2018, 1, 2, 14, 0))
Appointment.create!(executive: ex2,client_id: 1100,time: Time.zone.local(2018, 1, 4, 14, 0))

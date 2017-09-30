Region.create!(name: 'Región de Tarapacá')
Region.create!(name: 'Región del Libertador General Bernardo O\'Higgins')
Region.create!(name: 'Región del Maule')
metropolitana = Region.create(name: 'Región Metropolitana de Santiago')


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

metropolitana.save!

bo1 = BranchOffice.create!(address: 'Calle Principal #123', comuna_id: metropolitana.comunas[3].id)
bo2 = BranchOffice.create!(address: 'Paseo Bulnes #456', comuna_id: metropolitana.comunas[6].id)
bo3 = BranchOffice.create!(address: 'Av. Providencia #789', comuna_id: metropolitana.comunas[10].id)
bo4 = BranchOffice.create!(address: 'Autopista Central #101', comuna_id: metropolitana.comunas[20].id)


Staff.create!(branch_office: bo1, fullname: "juan cespedes", email: 'juan@mail.com', password: '123123', password_confirmation: '123123', position: Staff.positions[:executive])
Staff.create!(branch_office: bo2, fullname: "pedro vilches", email: 'pedro@mail.com', password: '123123', password_confirmation: '123123', position: Staff.positions[:executive])
Staff.create!(branch_office: bo4, fullname: "natalia guzman", email: 'natalia@mail.com', password: '123123', password_confirmation: '123123', position: Staff.positions[:manager])
Staff.create!(branch_office: bo3, fullname: "pablo silva", email: 'pablo@mail.com', password: '123123', password_confirmation: '123123', position: Staff.positions[:manager])
Staff.create!(branch_office: bo1, fullname: "carlos vasquez", email: 'carlos@mail.com', password: '123123', password_confirmation: '123123', position: Staff.positions[:supervisor])

Staff.create!(branch_office: nil, fullname: "rodrigo silva", email: 'admin@mail.com', password: '123123', password_confirmation: '123123', position: Staff.positions[:admin])

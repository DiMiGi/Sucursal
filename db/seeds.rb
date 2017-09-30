Staff.create!(email: 'juan@mail.com', password: '123123', password_confirmation: '123123', position: Staff.positions[:executive])
Staff.create!(email: 'pedro@mail.com', password: '123123', password_confirmation: '123123', position: Staff.positions[:executive])
Staff.create!(email: 'natalia@mail.com', password: '123123', password_confirmation: '123123', position: Staff.positions[:manager])
Staff.create!(email: 'pablo@mail.com', password: '123123', password_confirmation: '123123', position: Staff.positions[:manager])
Staff.create!(email: 'admin@mail.com', password: '123123', password_confirmation: '123123', position: Staff.positions[:admin])

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

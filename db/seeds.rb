# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Staff.create(email: 'juan@mail.com', password: '123123', password_confirmation: '123123', position: Staff.positions[:executive])
Staff.create(email: 'pedro@mail.com', password: '123123', password_confirmation: '123123', position: Staff.positions[:executive])
Staff.create(email: 'natalia@mail.com', password: '123123', password_confirmation: '123123', position: Staff.positions[:manager])
Staff.create(email: 'pablo@mail.com', password: '123123', password_confirmation: '123123', position: Staff.positions[:manager])
Staff.create(email: 'admin@mail.com', password: '123123', password_confirmation: '123123', position: Staff.positions[:admin])

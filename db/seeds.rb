# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# coding: utf-8 #8.4,8.5

User.create!(name: "Sample User",
              email: "sample@email.com",
              password: "password",
              password_confirmation: "password",
              affiliation: "管理者",
              admin: true)

User.create!(name: "上長A",
            email: "sampleA@email.com",
            password: "password",
            password_confirmation: "password",
            affiliation: "A",
            #employee_number: 2,
            #uid: 2,
            superior: true)
            
User.create!(name: "上長B",
            email: "sampleB@email.com",
            password: "password",
            password_confirmation: "password",
            affiliation: "B",
            #employee_number: 3,
            #uid: 3,
            superior: true)

User.create!(name: "平社員_Tanaka",
            email: "sam@email.com",
            password: "password",
            password_confirmation: "password",
            affiliation: "Z",
            #employee_number: 4,
            #uid: 4,
            superior: false)            

10.times do |n|#A03 60->10に変更
  name  = Faker::Name.name
  email = "sample-#{n+1}@email.com"
  password = "password"
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password)
end
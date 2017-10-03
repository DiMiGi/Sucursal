FactoryGirl.define do
  factory :staff do

    sequence :email do |n| "staff_username#{n}@mail.com" end
    names "roberto pablo"
    first_surname "caceres"
    second_surname "garcia"

    type "Supervisor"

    password "123456789"
    password_confirmation { password }

  end
end

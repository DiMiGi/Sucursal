FactoryGirl.define do
  factory :admin do

    sequence :email do |n| "admin_username#{n}@mail.com" end
    names "roberto pablo"
    first_surname "caceres"
    second_surname "garcia"

    type "Admin"

    password "123456789"
    password_confirmation { password }

  end
end

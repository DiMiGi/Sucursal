FactoryGirl.define do
  factory :manager do

    sequence :email do |n| "manager_username#{n}@mail.com" end
    names "roberto pablo"
    first_surname "caceres"
    second_surname "garcia"

    type "Manager"

    password "123456789"
    password_confirmation { password }

    association :branch_office

  end
end

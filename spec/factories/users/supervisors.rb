FactoryGirl.define do
  factory :supervisor do

    sequence :email do |n| "supervisor_username#{n}@mail.com" end
    names "roberto pablo"
    first_surname "caceres"
    second_surname "garcia"

    type "Supervisor"

    password "123456789"
    password_confirmation { password }

    association :branch_office
    association :attention_type

  end
end

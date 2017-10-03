FactoryGirl.define do
  factory :executive, class: 'Executive', parent: :staff do

    sequence :email do |n| "executive_username#{n}@mail.com" end
    names "roberto pablo"
    first_surname "caceres"
    second_surname "garcia"

    type "Executive"

    password "123456789"
    password_confirmation { password }

    association :branch_office
    association :attention_type

  end
end

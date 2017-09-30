FactoryGirl.define do
  factory :staff do

    sequence :email { |n| "username#{n}@mail.com" }
    names "roberto pablo"
    first_surname "caceres"
    second_surname "garcia"

    password  "123456789"
    password_confirmation  "123456789"

    trait :executive { position :executive }
    trait :supervisor { position :supervisor }
    trait :manager { position :manager }
    trait :admin {
      position :admin
      branch_office nil
    }

    association :branch_office

  end
end

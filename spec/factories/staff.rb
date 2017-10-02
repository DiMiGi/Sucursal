FactoryGirl.define do
  factory :staff do

    sequence :email do |n| "username#{n}@mail.com" end
    names "roberto pablo"
    first_surname "caceres"
    second_surname "garcia"

    position :supervisor

    password "123456789"
    password_confirmation { password }

    trait :executive do position :executive end
    trait :supervisor do position :supervisor end
    trait :manager do position :manager end
    trait :admin do
      position :admin
      branch_office nil
    end

    association :branch_office

  end
end

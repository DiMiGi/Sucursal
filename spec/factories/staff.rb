FactoryGirl.define do
  factory :staff, class: Staff do

    sequence :email do |n| "username#{n}@mail.com" end
    names "roberto pablo"
    first_surname "caceres"
    second_surname "garcia"
    password "123456789"
    password_confirmation { password }

    factory :executive, class: Executive, parent: :staff do
      association :branch_office
      association :attention_type
    end

    factory :supervisor, class: Supervisor, parent: :staff do
      association :branch_office
      association :attention_type
    end

    factory :manager, class: Manager, parent: :staff do
      association :branch_office
    end

    factory :admin, class: Admin, parent: :staff do
    end

  end
end

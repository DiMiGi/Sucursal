FactoryGirl.define do
  factory :day_off do

    association :branch_office, strategy: :null
    association :staff, strategy: :null

    day Date.new(2018, 05, 15)

    trait :global do
      association :branch_office, strategy: :null
      association :staff, strategy: :null
    end

    trait :executive do
      association :branch_office, strategy: :null
      association :staff, :factory => [:staff, :executive]
    end

    trait :branch_office do
      association :branch_office, :factory => [:branch_office]
      association :staff, strategy: :null
    end

  end
end

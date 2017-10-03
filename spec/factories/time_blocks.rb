FactoryGirl.define do
  factory :time_block do

    weekday 0
    hour 8
    minutes 0

    trait :monday do weekday 0 end
    trait :tuesday do weekday 1 end
    trait :wednesday do weekday 2 end
    trait :thursday do weekday 3 end
    trait :friday do weekday 4 end
    trait :saturday do weekday 5 end
    trait :sunday do weekday 6 end

    association :executive

  end
end

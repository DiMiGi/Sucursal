FactoryGirl.define do
  factory :appointment do

    association :executive

    day Date.new(2018, 05, 15)

  end
end
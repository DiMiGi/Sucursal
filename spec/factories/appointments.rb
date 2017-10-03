FactoryGirl.define do
  factory :appointment do

    association :executive

    time Time.new(2018, 05, 15, 13, 31, 6)

  end
end

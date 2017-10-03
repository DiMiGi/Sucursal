FactoryGirl.define do
  factory :executive_day_off do

    association :executive
    day Date.new(2018, 05, 15)
    type "ExecutiveDayOff"

  end
end

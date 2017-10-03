FactoryGirl.define do
  factory :branch_office_day_off do

    association :branch_office
    day Date.new(2018, 05, 15)
    type "BranchOfficeDayOff"


  end
end

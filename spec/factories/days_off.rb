FactoryGirl.define do
  factory :day_off do

    day Date.new(2018, 05, 15)

    factory :global_day_off, class: GlobalDayOff do
      type "GlobalDayOff"
    end

    factory :executive_day_off, class: ExecutiveDayOff do
      association :executive
      type "ExecutiveDayOff"
    end

    factory :branch_office_day_off, class: BranchOfficeDayOff do
      association :branch_office
      type "BranchOfficeDayOff"
    end

  end
end

FactoryGirl.define do
  factory :duration_estimation do

    association :branch_office
    association :attention_type
    duration 4

  end
end

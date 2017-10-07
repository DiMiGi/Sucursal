FactoryGirl.define do
  factory :appointment do

    association :executive

    client_id 5

    time DateTime.new(2018, 05, 15, 13, 31, 6)

  end
end

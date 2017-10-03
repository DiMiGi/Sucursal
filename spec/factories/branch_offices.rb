FactoryGirl.define do
  factory :branch_office do

    address "Calle Beijing #789"

    minute_discretization 5

    association :comuna

  end
end

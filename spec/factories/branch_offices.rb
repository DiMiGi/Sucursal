FactoryGirl.define do
  factory :branch_office do

    address "Calle Beijing #789"

    # Divisores de 60.
    minute_discretization 5

    association :comuna

  end
end

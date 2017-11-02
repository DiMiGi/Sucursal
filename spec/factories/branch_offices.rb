FactoryGirl.define do
  factory :branch_office do

    address "Calle Beijing #789"

    # Divisores de 60.
    minute_discretization 5

    association :comuna

    latitude -33.396434
    longitude -70.562218

  end
end

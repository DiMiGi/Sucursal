FactoryGirl.define do
  factory :branch_office do

    address "Calle Beijing #789"

    # Divisores de 60.
    minute_discretization 5

    association :comuna

    latitude { rand(-30..30) }
    longitude { rand(-30..30) }

  end
end

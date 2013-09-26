class Vehicle < Asset
  RENTAL = 'Rental Vehicle'
  GATOR = 'Gator'
  GOLF_CART = 'Golf Cart'
  DESIGNATIONS = [RENTAL, GATOR, GOLF_CART].freeze

  def possible_designations
    DESIGNATIONS
  end
end

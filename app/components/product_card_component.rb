class ProductCardComponent < ViewComponent::Base
  def initialize(product:)
    @product = product
  end

  private

  attr_reader :product
end

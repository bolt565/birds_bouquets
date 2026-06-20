class CartService
  CART_SESSION_KEY = :cart

  def initialize(session)
    @session = session
    @cart = session[CART_SESSION_KEY] || {}
  end

  def add_item(product_id, quantity = 1)
    product_id = product_id.to_s
    product = Product.find_by(id: product_id)
    return { success: false, error: "Product not found" } unless product
    return { success: false, error: "This product is currently out of stock" } unless product.in_stock?

    quantity = quantity.to_i
    return { success: false, error: "Invalid quantity" } unless quantity > 0

    @cart[product_id] = (@cart[product_id] || 0) + quantity
    save!
    { success: true }
  end

  def remove_item(product_id)
    @cart.delete(product_id.to_s)
    save!
  end

  def update_quantity(product_id, quantity)
    product_id = product_id.to_s
    quantity = quantity.to_i
    if quantity <= 0
      remove_item(product_id)
    else
      @cart[product_id] = quantity
      save!
    end
  end

  def items
    return [] if @cart.empty?

    product_ids = @cart.keys
    products = Product.where(id: product_ids).index_by { |p| p.id.to_s }

    @cart.filter_map do |product_id, quantity|
      product = products[product_id]
      next unless product

      {
        product: product,
        quantity: quantity,
        unit_price_cents: product.price_cents,
        line_total_cents: product.price_cents * quantity
      }
    end
  end

  def count
    @cart.values.sum
  end

  def total_cents
    items.sum { |item| item[:line_total_cents] }
  end

  def empty?
    @cart.empty?
  end

  def clear
    @session.delete(CART_SESSION_KEY)
    @cart = {}
  end

  def product_ids
    @cart.keys.map(&:to_i)
  end

  private

  def save!
    @session[CART_SESSION_KEY] = @cart
  end
end

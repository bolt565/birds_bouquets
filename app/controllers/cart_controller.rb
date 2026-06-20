class CartController < ApplicationController
  layout "landing"

  def show
    @items = current_cart.items
    @total_cents = current_cart.total_cents
  end

  def add_item
    result = current_cart.add_item(params[:product_id], params[:quantity] || 1)

    respond_to do |format|
      format.turbo_stream do
        if result[:success]
          flash.now[:notice] = "Added to cart!"
        else
          flash.now[:alert] = result[:error]
        end
        render turbo_stream: [
          turbo_stream.update("cart-count", current_cart.count.to_s),
          turbo_stream.update("flash", render_to_string(partial: "shared/flash"))
        ]
      end
      format.html do
        if result[:success]
          flash[:notice] = "Added to cart!"
        else
          flash[:alert] = result[:error]
        end
        redirect_back fallback_location: products_path
      end
    end
  end

  def remove_item
    current_cart.remove_item(params[:product_id])

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("cart-item-#{params[:product_id]}"),
          turbo_stream.update("cart-count", current_cart.count.to_s),
          turbo_stream.update("cart-total", helpers.number_to_currency(current_cart.total_cents / 100.0))
        ]
      end
      format.html { redirect_to cart_path }
    end
  end

  def update_item
    current_cart.update_quantity(params[:product_id], params[:quantity])
    redirect_to cart_path
  end
end

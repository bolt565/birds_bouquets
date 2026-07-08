class ProductsController < ApplicationController
  layout "landing"

  def index
    @products = Product.in_stock.ordered
    @categories = Category.active.ordered
    @current_category = nil

    if params[:category].present?
      @current_category = Category.active.find_by(slug: params[:category])
      @products = @products.by_category(@current_category) if @current_category
    end

    seo_meta(
      title: @current_category ? "#{@current_category.name} — Bird's Blossoms" : "Fresh Flowers — Bird's Blossoms",
      description: @current_category&.meta_description || "Shop our full collection of fresh flower bouquets and arrangements. Same-day delivery available.",
      url: products_url(category: params[:category]),
      keywords: "buy flowers online, fresh flowers, flower bouquets"
    )

    breadcrumb_structured_data([
      { name: "Home", url: root_url },
      { name: "Shop", url: products_url }
    ])
  end

  def show
    @product = Product.find_by!(slug: params[:id])
    @related_products = Product.in_stock.where(category: @product.category).where.not(id: @product.id).limit(4)

    seo_meta(
      title: @product.meta_title || "#{@product.name} — Bird's Blossoms",
      description: @product.meta_description || @product.description.truncate(160),
      url: product_url(@product),
      keywords: @product.meta_keywords
    )

    product_structured_data(@product)

    breadcrumb_structured_data([
      { name: "Home", url: root_url },
      { name: "Shop", url: products_url },
      { name: @product.category&.name || "Flowers", url: @product.category ? products_url(category: @product.category.slug) : products_url },
      { name: @product.name }
    ])
  end
end

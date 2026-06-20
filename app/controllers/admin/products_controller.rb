class Admin::ProductsController < Admin::BaseController
  before_action :set_product, only: [:edit, :update, :destroy, :toggle_in_stock, :toggle_featured]

  def index
    @products = Product.includes(:category, :product_images).ordered

    @products = @products.where("products.name ILIKE ?", "%#{params[:search]}%") if params[:search].present?
    @products = @products.by_category(Category.find_by(slug: params[:category])) if params[:category].present?
    @products = @products.where(in_stock: params[:in_stock] == "true") if params[:in_stock].present?

    @categories = Category.active.ordered
  end

  def new
    @product = Product.new
    @categories = Category.all.ordered
  end

  def create
    @product = Product.new(product_params)

    if @product.save
      handle_image_uploads
      flash[:notice] = "Product created."
      redirect_to admin_products_path
    else
      @categories = Category.all.ordered
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @categories = Category.all.ordered
  end

  def update
    if @product.update(product_params)
      handle_image_uploads
      flash[:notice] = "Product updated."
      redirect_to admin_products_path
    else
      @categories = Category.all.ordered
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @product.order_items.any?
      flash[:alert] = "Cannot delete: this product has existing orders."
      redirect_to admin_products_path and return
    end

    @product.destroy
    flash[:notice] = "Product deleted."
    redirect_to admin_products_path
  end

  def toggle_in_stock
    @product.update!(in_stock: !@product.in_stock?)
    flash[:notice] = "Product #{@product.in_stock? ? 'marked in stock' : 'marked out of stock'}."
    redirect_to admin_products_path
  end

  def toggle_featured
    @product.update!(featured: !@product.featured?)
    flash[:notice] = "Product #{@product.featured? ? 'featured' : 'unfeatured'}."
    redirect_to admin_products_path
  end

  private

  def set_product
    @product = Product.find_by!(slug: params[:id])
  end

  def product_params
    params.require(:product).permit(
      :name, :slug, :description, :price_dollars, :compare_at_price_dollars,
      :category_id, :in_stock, :featured, :position,
      :meta_title, :meta_description, :meta_keywords, :og_image_url
    ).tap do |p|
      p[:price_cents] = (p.delete(:price_dollars).to_f * 100).round if p[:price_dollars]
      p[:compare_at_price_cents] = (p.delete(:compare_at_price_dollars).to_f * 100).round if p[:compare_at_price_dollars]
    end
  end

  def handle_image_uploads
    return unless params[:product_images].present?

    params[:product_images].each_with_index do |image_file, index|
      @product.product_images.create!(
        position: @product.product_images.count + index,
        alt_text: @product.name
      ).tap { |pi| pi.image.attach(image_file) }
    end
  end
end

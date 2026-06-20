class Admin::CategoriesController < Admin::BaseController
  before_action :set_category, only: [:edit, :update, :destroy]

  def index
    @categories = Category.ordered.includes(:products)
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      flash[:notice] = "Category created."
      redirect_to admin_categories_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @category.update(category_params)
      flash[:notice] = "Category updated."
      redirect_to admin_categories_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @category.products.any?
      flash[:alert] = "Cannot delete: #{@category.products.count} products are in this category."
      redirect_to admin_categories_path and return
    end

    @category.destroy
    flash[:notice] = "Category deleted."
    redirect_to admin_categories_path
  end

  private

  def set_category
    @category = Category.find_by!(slug: params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :slug, :description, :position, :active, :meta_description, :meta_keywords)
  end
end

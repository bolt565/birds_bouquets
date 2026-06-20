class Admin::BlogPostsController < Admin::BaseController
  before_action :set_post, only: [:edit, :update, :destroy, :publish, :unpublish]

  def index
    @posts = BlogPost.order(created_at: :desc)
  end

  def new
    @post = BlogPost.new(status: "draft")
  end

  def create
    @post = BlogPost.new(post_params)
    if @post.save
      flash[:notice] = "Post created."
      redirect_to admin_blog_posts_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @post.update(post_params)
      flash[:notice] = "Post updated."
      redirect_to admin_blog_posts_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    flash[:notice] = "Post deleted."
    redirect_to admin_blog_posts_path
  end

  def publish
    @post.publish!
    flash[:notice] = "Post published."
    redirect_to admin_blog_posts_path
  end

  def unpublish
    @post.unpublish!
    flash[:notice] = "Post unpublished."
    redirect_to admin_blog_posts_path
  end

  private

  def set_post
    @post = BlogPost.find_by!(slug: params[:id])
  end

  def post_params
    params.require(:blog_post).permit(:title, :slug, :body, :excerpt, :status, :author_name, :published_at, :meta_title, :meta_description, :meta_keywords, :og_image_url)
  end
end

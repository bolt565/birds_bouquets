class BlogController < ApplicationController
  layout "landing"

  def index
    @posts = BlogPost.published.limit(12).offset(page_offset)
    @total_pages = (BlogPost.published.count / 12.0).ceil

    seo_meta(
      title: "Flower Care Tips & Inspiration — Birds Bouquets Blog",
      description: "Discover flower care tips, arrangement ideas, and floral inspiration on the Birds Bouquets blog.",
      url: blog_url
    )
  end

  def show
    @post = BlogPost.published.find_by!(slug: params[:slug])

    seo_meta(
      title: @post.meta_title || "#{@post.title} — Birds Bouquets",
      description: @post.meta_description || @post.excerpt || @post.body.truncate(160),
      url: blog_show_url(slug: @post.slug),
      keywords: @post.meta_keywords
    )

    article_structured_data(@post)
    breadcrumb_structured_data([
      { name: "Home", url: root_url },
      { name: "Blog", url: blog_url },
      { name: @post.title }
    ])
  end

  private

  def page_offset
    ([params[:page].to_i, 1].max - 1) * 12
  end
end

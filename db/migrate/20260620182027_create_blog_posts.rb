class CreateBlogPosts < ActiveRecord::Migration[7.2]
  def change
    create_table :blog_posts do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.text :body, null: false
      t.text :excerpt
      t.string :meta_title
      t.string :meta_description
      t.string :meta_keywords
      t.string :og_image_url
      t.string :status, default: "draft"
      t.datetime :published_at
      t.string :author_name

      t.timestamps
    end

    add_index :blog_posts, :slug, unique: true
    add_index :blog_posts, :status
  end
end

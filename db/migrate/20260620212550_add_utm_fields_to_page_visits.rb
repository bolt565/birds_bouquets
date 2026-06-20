class AddUtmFieldsToPageVisits < ActiveRecord::Migration[7.2]
  def change
    add_column :page_visits, :utm_content, :string
    add_column :page_visits, :utm_term, :string
    add_index :page_visits, :created_at unless index_exists?(:page_visits, :created_at)
    add_index :page_visits, :utm_source unless index_exists?(:page_visits, :utm_source)
    add_index :page_visits, :user_id unless index_exists?(:page_visits, :user_id)
  end
end

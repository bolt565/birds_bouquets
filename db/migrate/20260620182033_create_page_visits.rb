class CreatePageVisits < ActiveRecord::Migration[7.2]
  def change
    create_table :page_visits do |t|
      t.references :user, null: true, foreign_key: true
      t.string :landing_url
      t.string :referring_url
      t.string :utm_source
      t.string :utm_medium
      t.string :utm_campaign
      t.string :ip_address
      t.string :user_agent

      t.datetime :created_at, null: false
    end
  end
end

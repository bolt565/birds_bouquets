class CreateEmailLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :email_logs do |t|
      t.references :user, null: true, foreign_key: true
      t.string :mailer_class
      t.string :mailer_action
      t.string :to_email
      t.string :subject
      t.text :body_html

      t.datetime :created_at, null: false
    end
  end
end

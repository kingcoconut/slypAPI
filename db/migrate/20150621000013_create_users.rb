class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string  :email
      t.string  :facebook_id
      t.string  :api_token
      t.string  :profile_image_url
      t.string  :encrypted_password
      t.string  :salt
      t.string  :name

      t.timestamps
    end
  end
end
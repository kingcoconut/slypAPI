class AddLastEmailedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sign_in_count, :integer, default: 0
    add_column :users, :last_emailed_at, :datetime
  end
end

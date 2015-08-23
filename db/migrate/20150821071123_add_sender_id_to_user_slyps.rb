class AddSenderIdToUserSlyps < ActiveRecord::Migration
  def change
    add_column :user_slyps, :sender_id, :integer
  end
end

class CreateSlypChatUsers < ActiveRecord::Migration
  def change
    create_table :slyp_chat_users do |t|
      t.integer :user_id
      t.integer :slyp_chat_id
      t.timestamps
    end
  end
end

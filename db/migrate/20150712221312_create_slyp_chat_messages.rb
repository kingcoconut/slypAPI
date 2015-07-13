class CreateSlypChatMessages < ActiveRecord::Migration
  def change
    create_table :slyp_chat_messages do |t|
      t.integer :user_id
      t.integer :slyp_chat_id
      t.text :content
      t.timestamps
    end
  end
end

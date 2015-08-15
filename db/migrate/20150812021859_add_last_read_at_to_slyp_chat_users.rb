class AddLastReadAtToSlypChatUsers < ActiveRecord::Migration
  def change
    add_column :slyp_chat_users, :last_read_at, :timestamp, default: Time.new(2000)
  end
end

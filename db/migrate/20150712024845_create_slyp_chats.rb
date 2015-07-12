class CreateSlypChats < ActiveRecord::Migration
  def change
    create_table :slyp_chats do |t|
      t.integer :slyp_id
      t.timestamps
    end
  end
end

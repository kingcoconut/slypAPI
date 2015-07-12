class AddUserSlyps < ActiveRecord::Migration
  def change
    create_table :user_slyps do |t|
      t.integer  :slyp_id
      t.integer  :user_id
      t.timestamps
    end
  end
end

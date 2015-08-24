class AddLovedToUserSlyps < ActiveRecord::Migration
  def change
    add_column :user_slyps, :loved, :boolean, default: false
  end
end

class RemoveOriginFromUserSlyps < ActiveRecord::Migration
  def change
    remove_column :user_slyps, :origin
  end
end

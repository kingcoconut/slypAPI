class AddOriginToUserSlyps < ActiveRecord::Migration
  def change
    add_column :user_slyps, :origin, :integer
  end
end

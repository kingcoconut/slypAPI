class ChangeLovedToStarred < ActiveRecord::Migration
  def change
    rename_column :user_slyps, :loved, :starred
  end
end

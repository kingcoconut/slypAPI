class AddArchivedToUserSlyps < ActiveRecord::Migration
  def change
    add_column :user_slyps, :archived, :boolean, default: false
  end
end

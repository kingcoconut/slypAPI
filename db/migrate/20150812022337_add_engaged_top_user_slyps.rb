class AddEngagedTopUserSlyps < ActiveRecord::Migration
  def change
    add_column :user_slyps, :engaged, :boolean, default: false
  end
end

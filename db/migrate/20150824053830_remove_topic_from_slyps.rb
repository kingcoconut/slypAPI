class RemoveTopicFromSlyps < ActiveRecord::Migration
  def change
    remove_column :slyps, :topic
  end
end

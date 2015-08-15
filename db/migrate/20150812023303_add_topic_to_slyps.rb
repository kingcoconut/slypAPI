class AddTopicToSlyps < ActiveRecord::Migration
  def change
    add_reference(:slyps, :topic)
  end
end

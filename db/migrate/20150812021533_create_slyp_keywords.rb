  class CreateSlypKeywords < ActiveRecord::Migration
  def change
    create_table :slyp_keywords do |t|
      t.references :keyword
      t.references :slyp
      t.timestamps
    end
  end
end

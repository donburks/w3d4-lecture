class AddCapacityToMalls < ActiveRecord::Migration
  def change
    change_table :malls do |t|
      t.integer :capacity, default: 10
    end
  end
end
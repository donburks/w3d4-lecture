class CreateTables < ActiveRecord::Migration
  def change
    create_table :malls do |t|
      t.string :name
      t.string :city
      t.integer :revenue, default: 0
      t.timestamps
    end

    create_table :stores do |t|
      t.string :name
      t.string :category
      t.references :mall
      t.timestamps
    end
  end
end
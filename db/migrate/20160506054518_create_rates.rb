class CreateRates < ActiveRecord::Migration
  def change
    create_table :rates do |t|
      t.integer :agent_id
      t.integer :customer_id
      t.integer :rate
      t.text :comment

      t.timestamps null: false
    end
  end
end

class CreateWorkingPlaces < ActiveRecord::Migration[5.1]
  def change
    create_table :working_places do |t|
      t.integer :working_place_number
      t.string :working_place_name
      t.string :working_place_type

      t.timestamps
    end
  end
end

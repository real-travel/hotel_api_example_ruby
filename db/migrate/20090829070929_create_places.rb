class CreatePlaces < ActiveRecord::Migration
  def self.up
    create_table :places do |t|
      t.integer :parent_id
      t.string :type, :null => false, :limit => 32
      t.string :name, :null => false, :limit => 128
      t.string :abbreviation, :limit => 8
      t.decimal :latitude, :precision => 16, :scale => 10
      t.decimal :longitude, :precision => 16, :scale => 10
    end
    
    add_index :places, :name
    add_index :places, :abbreviation
    add_index :places, :parent_id
    
  end

  def self.down
    drop_table :places
  end
end

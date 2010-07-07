class AddAlternateTitle < ActiveRecord::Migration
  def self.up
    add_column :pages, :alternate_title, :string
  end
  
  def self.down
    remove_column :pages, :alternate_title
  end
end
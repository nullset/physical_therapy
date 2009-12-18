class CreatePageAssociations < ActiveRecord::Migration
  def self.up
    create_table "page_associations" do |t|
      t.column "page_attachment_id", :integer
      t.column "page_id", :integer
    end
  end

  def self.down
    drop_table "page_associations"
  end
end
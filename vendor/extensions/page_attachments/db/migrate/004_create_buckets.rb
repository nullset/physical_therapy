class CreateBuckets < ActiveRecord::Migration
  def self.up
    create_table "buckets" do |t|
      t.column "user_id", :integer
      t.column "page_attachment_id", :integer
    end
  end

  def self.down
    drop_table "buckets"
  end
end
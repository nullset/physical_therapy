class PageAsset < ActiveRecord::Base
  belongs_to :resource, :polymorphic => true
  belongs_to :nice_asset, :class_name => "NiceAsset", :foreign_key => "resource_id"
  belongs_to :page, :class_name => "Page", :foreign_key => "resource_id"
end

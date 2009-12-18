class PageAssociation < ActiveRecord::Base
  belongs_to :page
  belongs_to :page_attachment
end

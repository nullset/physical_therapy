class Admin::AssetsController < ApplicationController

  def index
    @assets = PageAttachment.find(:all, :conditions => "parent_id is null", :order => "created_at desc")
  end

end
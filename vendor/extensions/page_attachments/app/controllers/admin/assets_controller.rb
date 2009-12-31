class Admin::AssetsController < ApplicationController

  def index
    @assets = PageAttachment.find(:all, :conditions => "parent_id is null", :order => "created_at desc")
  end
  
  def popup
    @type = params[:type]
    case @type
    when 'image'
      @files = PageAttachment.find(:all, :conditions => "parent_id is null and content_type like 'image%'", :order => "created_at desc")
    else
      @files = PageAttachment.find(:all, :conditions => "parent_id is null", :order => "created_at desc")
      @pages = Page.find(:all)
    end
    render :action => "popup", :layout => false
  end
  
  def uploader
    render :action => "uploader", :layout => false
  end
  
  def page_tree
    # @pages = Page.find(:all, :order => "parent_id")
    @homepage = Page.find_by_parent_id(nil)
    render :action => "page_tree", :layout => false
  end

end
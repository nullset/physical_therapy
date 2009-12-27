require 'mime/types'

class PageAttachmentsController < ApplicationController
  
  skip_before_filter :authenticate, :authorize
  
  protect_from_forgery :except => [:create]
  # FIXME : need to figure out why authorization isn't happening
  # http://railstips.org/2009/7/21/uploadify-and-rails23
  # http://code.google.com/p/swfupload/
  # http://gist.github.com/11753
  # http://www.ruby-forum.com/topic/167917
  
  def create
    @user = User.find(params[:user_id])
    @nice_asset = PageAttachment.new(
      :uploaded_data => params[:uploaded_data],
      # :page_id => @page.id,
      :created_by => @user,
      :updated_by => @user,
      :title => params[:title]
    )

    mime_type = MIME::Types.type_for(@nice_asset.public_filename)
    @nice_asset.content_type = mime_type unless mime_type.blank?
    @nice_asset.save!

    if params[:page_id]
      @page = Page.find(params[:page_id])
      @page_association = PageAssociation.create(:page_attachment_id => @nice_asset.id, :page_id => @page.id)
      @page_association.save!
      render :partial => 'admin/pages/nice_asset', :object => @nice_asset
    else
      render :partial => 'admin/pages/nice_asset_row', :object => @nice_asset
    end
    # render :update do |page|
    #   # page.insert_html :bottom, 'nice_assets', :partial => 'admin/pages/nice_asset'
    #   # page.visual_effect :highlight, 'nice_assets_box'
    #   page.alert 'booo'
    # end
  end
  
  def delete
    asset = PageAttachment.find(params[:id])
    if asset.destroy
      render :update do |page|
      end
    end
  end
  
  def delete_from_page
    association = PageAssociation.find(:first, :conditions => ["page_attachment_id = ? and page_id = ?", params[:id], params[:page_id]])
    if association.destroy
      render :update do |page|
      end
    end
  end
  
end
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
    @page = Page.find(params[:page_id])
    @nice_asset = PageAttachment.new(
      :uploaded_data => params[:uploaded_data],
      :page_id => @page.id,
      :created_by => @user,
      :updated_by => @user
    )

    @nice_asset.content_type = MIME::Types.type_for(@nice_asset.public_filename)
    @nice_asset.save!
    # render :update do |page|
    #   # page.insert_html :bottom, 'nice_assets', :partial => 'admin/pages/nice_asset'
    #   # page.visual_effect :highlight, 'nice_assets_box'
    #   page.alert 'booo'
    # end
    render :partial => 'admin/pages/nice_asset', :object => @nice_asset
  end

end
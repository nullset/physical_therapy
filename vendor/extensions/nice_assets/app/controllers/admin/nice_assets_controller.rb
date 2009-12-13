class Admin::NiceAssetsController < ApplicationController
  
  skip_before_filter :authenticate, :authorize
  
  protect_from_forgery :except => [:create]
  # FIXME : need to figure out why authorization isn't happening
  # http://railstips.org/2009/7/21/uploadify-and-rails23
  # http://code.google.com/p/swfupload/
  # http://gist.github.com/11753
  # http://www.ruby-forum.com/topic/167917
  
  def create
    g params.to_yaml
    params[:upload] = {:uploaded_data => params[:uploaded_data]}
    @attachable_file = PageAttachment.new(params[:upload])
    debugger
    @attachable_file.save!
    render :nothing => true
  end

  # browse function
  # find assets of a particular type(s)
  def get_assets
    content_type = params[:type]
    unless params[:paginate] == "true"
      add_or_remove_content_type(content_type)
    end
    @assets = NiceAsset.find_by_content_types(session[:content_types], session[:sort_order], (params[:page] ||= 0))
    render :update do |page|
      if session[:content_types].nil? or session[:content_types].length == 0
        page << %{$('browse-order').disabled = 'disabled';}
      else
        page << %{$('browse-order').disabled= '';}
      end
      if !@assets.nil? and @assets.size > 0
        page.replace_html 'asset-list', :partial => 'admin/nice_assets/asset_thumbnail', :collection => @assets, :locals => {:add_msg => "Add file to the asset clipboard for this page.", :delete_msg => 'Delete this file from your entire site.'}
        page.replace_html 'asset-pagination', :partial => 'admin/nice_assets/paginate', :locals => {:collection => @assets}
      else
        page << %{$('browse-order').disabled = 'disabled';}
        page.replace_html 'asset-list', "No files found."
      end
      page.hide 'asset-browse-loading'
    end
  end
  
  # browse function
  # sort assets by criteria
  def sort_assets
    session[:sort_order] = params[:order]
    @assets = NiceAsset.find_by_content_types(session[:content_types], session[:sort_order])
    render :update do |page|
      if !@assets.nil?
        page.replace_html 'asset-list', :partial => 'admin/nice_assets/asset_thumbnail', :collection => @assets, :locals => {:add_msg => "Add file to the asset clipboard for this page.", :delete_msg => 'Delete this file from your entire site.'}
      else
        page.replace_html 'asset-list', ""
      end
      page.hide 'asset-browse-loading'
    end
  end
  
  # def create
  #   frame = params[:id]
  #   asset = NiceAsset.create! params[:asset]
  #   responds_to_parent do
  #     render :update do |page|
  #       page.insert_html :top, "page-assets", :partial => 'admin/nice_assets/new_asset_thumbnail', :object => asset, :locals => {:add_msg => "Add to this page at cursor position", :delete_msg => 'Remove from the asset clipboard'}
  #       page.remove("upload-form-#{frame}")
  #       page.remove("upload-image-#{frame}")
  #       page.insert_html :top, "upload_#{frame}", %{<img src="/images/extensions/nice_assets/accept.png" width="16" height="16" alt="" /> <strong>#{asset.filename}</strong> uploaded}
  #       page.visual_effect :highlight, "upload_#{frame}"
  #     end
  #   end
  # end
  
  def browse_pages
    if session[:expanded_nodes].nil?
      session[:expanded_nodes] = []
    end
    
    begin
      @page = Page.find(params[:page])
    rescue
      @page = nil
    end
    if params[:node]
      @node = Page.find(params[:node])
    end
    # raise @child_id.inspect
    @root = Page.find(:first, :conditions => ['parent_id IS NULL'])
    @current_page = @page
    render :update do |page|
      if !@node.nil?
        if !session[:expanded_nodes].include?(@node.id) and @node.children
          session[:expanded_nodes] << @node.id
          page.insert_html :bottom, "node-#{@node.id}", :partial => 'child_pages', :locals => {:node => @node}
          page << %{
            elm = $('node-#{@node.id}');
            elm.cleanWhitespace();
            expander = elm.firstChild;
            expander.removeClassName('spinner');
            expander.addClassName('collapser');
          }
        else
          page << %{ 
            elm = $('node-#{@node.id}');
            elm.cleanWhitespace();
            elm.lastChild.remove();
            expander = elm.firstChild;
            expander.removeClassName('collapser');
            expander.removeClassName('spinner');
          }
          session[:expanded_nodes].delete(@node.id)
        end
      else
        if session[:expanded_nodes].length == 0
          page.replace_html 'page-browser', :partial => 'admin/nice_assets/browse_pages', :locals => {:current_page => @page}
        end
      end
    end
  end
  
  # add a page to the asset clipboard
  def link_page
    current_page = Page.find(params[:id])
    linked_page = Page.find(params[:page])
    render :update do |page|
      page << %{$('page-browse-loading').removeClassName('loading-indicator')};
      page << %{$('page-browse-loading').addClassName('page-added-indicator')};
      page.insert_html :top, "page-assets", :partial => 'admin/nice_assets/new_asset_thumbnail', :object => linked_page, :locals => {:add_msg => "Add to this page at cursor position", :delete_msg => 'Remove from the asset clipboard'}
      page.delay(0.3) do
        page.visual_effect :fade, 'page-browse-loading', {:duration => 0.5}
        page.delay(0.5) do
          page << %{$('page-browse-loading').removeClassName('page-added-indicator')};
          page << %{$('page-browse-loading').addClassName('loading-indicator')};
        end
      end
    end
  end
  
  # add a file to the asset clipboard
  ## TODO : should probably condense this and :link_page into one function for DRY purposes
  def add_to_clipboard
    page_id, resource_type, resource_id, elem = params[:page], params[:resource_type], params[:resource_id], params[:element]
    asset = get_asset(resource_type, resource_id)
    render :update do |page|
      page << %{$('asset-browse-loading').removeClassName('loading-indicator')};
      page << %{$('asset-browse-loading').addClassName('asset-added-indicator')};
      page.insert_html :top, "page-assets", :partial => 'admin/nice_assets/new_asset_thumbnail', :object => asset, :locals => {:add_msg => "Add to this page at cursor position", :delete_msg => 'Remove from the asset clipboard'}
      page.delay(0.3) do
        page.visual_effect :fade, 'asset-browse-loading', {:duration => 0.5}
        page.delay(0.5) do
          page << %{$('asset-browse-loading').removeClassName('asset-added-indicator')};
          page << %{$('asset-browse-loading').addClassName('loading-indicator')};
        end
      end
    end
  end
  
  def asset_information
    resource_type, resource_id = params[:resource_type], params[:resource_id]
    asset = get_asset(resource_type, resource_id)
    render :update do |page|
      page.replace_html 'asset-information', :partial => 'admin/nice_assets/asset_information', :object => asset
    end
  end
  
  def remove_from_clipboard
    elem, resource_type, resource_id = params[:elem], params[:resource_type], params[:resource_id]
    asset = eval("#{resource_type}.find(#{resource_id})")
    url = get_asset_url(asset)
    page_asset = PageAsset.find(:first, :conditions => ["page_id = ? and resource_type = ? and resource_id = ?", id, resource_type, resource_id])
    page = Page.find(params[:id])
    page.parts.each_with_index do |part, i|
      if content = remove_asset_from_page_part(part, url)
        render :update do |page|
          page << %{$('part[#{i}][content]').value = decodeURIComponent("#{content}");}
        end
      else
        render :update do |page|
        
        end
      end
    end
  end
  
  def destroy
    asset = NiceAsset.find(params[:id])
    if params[:force] && params[:force] == 'true'
      asset.destroy
      render :update do |page|
        page.hide 'asset-browse-loading'
        page.visual_effect :DropOut, "asset-#{params[:html_id]}"
      end
    else
      pages = Page.find(:all, :include => :page_assets, :conditions => ["page_assets.resource_type = 'NiceAsset' and page_assets.resource_id = ?", params[:id]])
      if pages.empty?
        asset.destroy
        render :update do |page|
          page.hide 'asset-browse-loading'
          page.visual_effect :DropOut, "asset-#{params[:html_id]}"
        end
      else
        render :update do |page|
          page << %{$('asset-browse-loading').removeClassName('loading-indicator')};
          page << %{$('asset-browse-loading').addClassName('browse-asset-message')};
          page.replace_html 'asset-browse-message', %{<img src="#{asset.thumbnail_public_filename('100')}" alt="#{asset.filename}" class="floatLeft" /><p>The file you are trying to delete is still being used on the following pages. Please remove the file from these pages first and then try again.</p>}
          page.insert_html :bottom, 'asset-browse-message', :partial => 'admin/nice_assets/delete_warnings', :object => pages, :locals => { :asset => asset, :html_id => params[:html_id] }
        end
      end
    end
  end
  
  # upload
  # add an asset upload form to the upload modal dialog
  def add_asset_form
    page_id, style = params[:id], params[:style]
    render :update do |page|
      page.insert_html :before, 'add-another-file', :partial => 'admin/nice_assets/upload_div', :locals => { :id => Time.now.to_f.to_s.sub(/\./, ''), :page => page_id, :style => style }
    end
  end
  
  def remove_page
    @page = Page.find(params[:id])
    if request.post?
      announce_pages_removed(@page.children.count + 1)
      @page.destroy
      redirect_to page_index_url
    end
  end
  
  private
  
  def announce_pages_removed(count)
    flash[:notice] = if count > 1
      "The pages were successfully removed from the site."
    else
      "The page was successfully removed from the site."
    end
  end
  
  def add_or_remove_content_type(content_type)
    if session[:content_types].nil?
      session[:content_types] = []
    end
    if session[:content_types].include?(content_type)
      session[:content_types].delete(content_type)
    else
      session[:content_types] << content_type
    end
  end
  
  # generic function to get an asset of any type
  def get_asset(resource_type, resource_id)
    asset = eval(resource_type).find(resource_id)
  end
  
  # generic function to get an asset's publicly available URL
  def get_asset_url(asset)
    begin
      return asset.url
    rescue
      return asset.public_filename
    end
  end

end
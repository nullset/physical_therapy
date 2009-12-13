require 'nokogiri'

class NiceAssetsExtension < Radiant::Extension
  version "1.0"
  description "Extension to handle asset uploads, placement, and linking. Extension © 2007 - Nathan Wright"
  
  url "http://www.brandalism.com"
  
  # define_routes do |map|
  #   map.connect 'admin/files/:action', :controller => 'admin/files'
  #   # map.connect 'admin/nice_asset/:action', :controller => 'admin/asset'
  # end
  
  # define_routes do |map|
  #   map.with_options(:controller => 'admin/nice_assets') do |nice_assets|
  #     nice_assets.get_assets   'admin/nice_assets/get_assets/:type', :action => 'get_assets',    :type => nil
  #     nice_assets.sort_assets  'admin/nice_assets/sort_assets',       :action =>  'sort_assets'
  #     nice_assets.destroy_asset      'admin/nice_assets/destroy/:id',          :action => 'destroy'
  #     nice_assets.add_asset_form   'admin/nice_assets/add_asset_form/:id',    :action => 'add_asset_form'
  #     nice_assets.add_to_clipboard   'admin/nice_assets/add_to_clipboard',    :action => 'add_to_clipboard'
  #     nice_assets.remove_from_clipboard   'admin/nice_assets/remove_from_clipboard/:id',    :action => 'remove_from_clipboard'
  #     nice_assets.asset_information   'admin/nice_assets/asset_information',    :action => 'asset_information'
  #     nice_assets.browse_pages  'admin/nice_assets/browse_pages',      :action => 'browse_pages'
  #     nice_assets.link_page     'admin/nice_assets/link_page/:id',      :action => 'link_page'
  #     nice_assets.create_asset          'admin/nice_assets/create/:id',              :action => 'create'
  #   end
  #   
  #   map.with_options(:controller => 'admin/nice_assets') do |pages|
  #     pages.remove_page  'admin/pages/remove/:id', :action => 'remove_page'
  #   end
  #   
  # end
  
  define_routes do |map|
    map.connect 'nice_assets/:action/:id', :controller => 'admin/nice_assets'
  end
  
  def activate
    Page.send :include, NiceAssetTags
    Admin::PagesController.send :include, NiceAssetsInterface
    
    # Page.class_eval do
    #   has_many :page_assets, :order => 'created_at desc'
    #   has_many :files, :through => :page_assets, :source => :nice_asset, :conditions => "page_assets.resource_type = 'NiceAsset'"
    #   has_many :pages, :through => :page_assets, :source => :page, :conditions => "page_assets.resource_type = 'Page'"
    #   has_many :linked_pages, :through => :page_assets, :source => :page
    #   before_destroy :remove_page_assets
    #   
    #   def new_assets=(new_assets)
    #     if not new_assets.nil?
    #       new_assets.each do |new_asset|
    #         a = new_asset.to_a
    #         h = {}
    #         a.each do |k, v|
    #           h[k] = v
    #         end
    #         page_assets = PageAsset.find(:first, :conditions => ['page_id = ? and resource_type = ? and resource_id = ?', self, h['resource_type'], h['resource_id']])
    #         unless page_assets
    #           self.page_assets << PageAsset.create(:resource_type => h['resource_type'], :resource_id => h['resource_id'])
    #         end
    #       end
    #     end
    #   end
    #   
    #   def removed_assets=(assets)
    #     if not assets.nil?
    #       assets.each do |asset|
    #         asset = asset.split(';')
    #         resource_type, resource_id = asset[0].split(':')[1], asset[1].split(':')[1]
    #         page_asset = PageAsset.find(:first, :conditions => ["page_id = ? and resource_type = ? and resource_id = ?", self.id, resource_type, resource_id])
    #         page_asset.destroy
    #       end
    #     end
    #   end
    #   
    #   def all_assets
    #     assets = []
    #     page_assets = self.page_assets
    #     page_assets.each do |pa|
    #       if pa.resource_type == 'NiceAsset'
    #         assets << pa.nice_asset
    #       elsif pa.resource_type == 'Page'
    #         assets << pa.page
    #       end
    #     end
    #     return assets
    #   end
    #   
    #   def remove_page_assets
    #     PageAsset.destroy_all("(resource_type = 'Page' and resource_id = #{self.id}) or (page_id = #{self.id})")
    #   end
    #   
    # end

    # end Page
    
    PagePart.class_eval do
    # Page.class_eval do
      before_save :generate_images  # automatically tacks the correct size onto the end of the image path and generates the image
      
      private
      
      def generate_images
        case self.filter_id
        when /^(Markdown|Maruku)$/
          self.content = replace_markdown_images
        when /^Textile$/
        else
          self.content = replace_html_images
        end
        # content = self.content
        # content = content.gsub(/<img.*?\/?>/) {|match| replace_html_image(match)} # takes any HTML image tag and ensures that the width/height listed correspond to as acts_as_attachment image filename
        # if self.filter_id == 'Markdown' or self.filter_id == 'Maruku'
        #   content = content.gsub(/![^\)]*?\)/) {|match| replace_markdown_image(match) }
        # elsif self.filter_id == 'Textile'
        #   content = content.gsub(/![^!]*?!/) {|match| replace_textile_image(match) }
        # end
        # self.content = content
      end
      
      def replace_html_images
        unless self.content.blank?
          doc = Nokogiri::HTML.fragment(self.content)
          images = doc.css('img')
          images.each do |img|
            width = img.attribute('width').to_s.to_i == 0 ? nil : img.attribute('width').to_s.to_i
            height = img.attribute('height').to_s.to_i == 0 ? nil : img.attribute('height').to_s.to_i
            src = img.attribute('src')
          

            file_id_components = src.to_s.scan(/^.*?([0-9]{4})\/([0-9]{4}).*?$/).first
            file_id = (file_id_components.first.to_i * 10000) + (file_id_components.last.to_i)

            size_conditions = []
            size_conditions << "width = #{width}" unless width.blank?
            size_conditions << "height = #{height}" unless height.blank?
            size_conditions.collect! {|c| " and #{c}"}
          
            image = PageAttachment.find(:first, :conditions => ["parent_id = ?#{size_conditions}", file_id])
            if image
              thumbnail_name = image.thumbnail
            else
              orig_image = PageAttachment.find(file_id)
              size = "#{width}x#{height}"
              g size
              image = orig_image.create_or_update_thumbnail(orig_image.full_filename, size, size )
            end
            unless image.thumbnail == 'icon'
              image.update_attributes(:filename => "#{File.basename(image.parent.filename, '.*')}_#{image.width}x#{image.height}#{File.extname(image.parent.filename)}", :thumbnail => "#{image.width}x#{image.height}")
            end
          

            img.set_attribute('src', image.public_filename)
            img.set_attribute('width', image.width.to_s) unless image.width.blank?
            img.set_attribute('height', image.height.to_s) unless image.height.blank?
            # raise img.inspect
          end
          doc.to_s
        end
      end
     
      def replace_textile_images
          raise img.inspect
          img_path = img.gsub(/(^!|!$|\(.*\)?)/, '').split('/')
          asset_id = img_path[-2].sub(/^0*/, '')

          file_name = img_path[-1]
          existing_asset = NiceAsset.find(:first, :conditions => ['filename = ? and parent_id = ?', file_name, asset_id])
          unless existing_asset
            suffix = File.basename(file_name, ".*").split('_').pop
            asset = NiceAsset.find(asset_id)
            size = asset.height > asset.width ? "x#{suffix}" : suffix
            thumb = asset.create_or_update_thumbnail(asset.full_filename, suffix, size)
            thumb.save
          end
      end
      
      def replace_markdown_images
        content = self.content.gsub(/![^\)]*?\)/) {|img| 
          img_path = img.gsub(/(^.*?\(|\s.*?\)$)/, '').split('/')
          asset_id = img_path[-2].sub(/^0*/, '')
          file_name = img_path[-1]
          existing_asset = NiceAsset.find(:first, :conditions => ['filename = ? and parent_id = ?', file_name, asset_id])
          unless existing_asset
            suffix = File.basename(file_name, ".*").split('_').pop
            begin
              asset = NiceAsset.find(asset_id)
              size = asset.height > asset.width ? "x#{suffix}" : suffix
              thumb = asset.create_or_update_thumbnail(asset.full_filename, suffix, size)
              thumb.save
            rescue
            end
          end
        }
        self.content = content
      end
      
    end
    # end PagePart
    
    
  end
  
  def deactivate
    # admin.tabs.remove "Nice Asset"
  end
      
end

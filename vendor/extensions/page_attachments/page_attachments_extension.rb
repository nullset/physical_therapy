require_dependency 'application_controller'
require 'nokogiri'
# require File.dirname(__FILE__) + '/lib/geometry'
# require 'tempfile'

class PageAttachmentsExtension < Radiant::Extension
  version "1.0"
  description "Adds page-attachment-style asset management."
  url "http://radiantcms.org"

   define_routes do |map|
     map.connect 'page_attachments/:action/:id', :controller => 'page_attachments'
     map.connect 'admin/pages/tree', :controller => "admin/pages", :action => 'tree'

     map.namespace :admin do |admin|
       admin.resources :assets,
        :collection => {
          :popup => :get,
          :uploader => :any,
          :page_tree => :get
        }
     end
   end

  def activate
    # Regular page attachments stuff
    Page.class_eval {
      include PageAttachmentAssociations
      include PageAttachmentTags
      
      has_many :page_associations
      has_many :page_attachments, :through => :page_associations
    }
    UserActionObserver.send :include, ObservePageAttachments
    Admin::PagesController.send :include, PageAttachmentsInterface
    
    # admin.nav["content"] << admin.nav_item(:assets, "Assets", "/admin/assets")
    
    PagePart.class_eval do
    # Page.class_eval do
      before_save :cleanup
      before_save :generate_images  # automatically tacks the correct size onto the end of the image path and generates the image
      
      private
      
      def cleanup
        unless self.content.blank?
          # Remove leading/trailing whitespace
          self.content = self.content.strip
        
          # Remove XML pasted from word docs
          self.content = self.content.gsub(/<!--\[if(.|\W)*?<!(--)?\[endif\]-->/, '')
          self.content = self.content.gsub(/\sclass="Mso[^"]*"/, '')
        
          # Remove trailing empty paragraphs
          self.content = self.content.gsub(/<p>\W*&nbsp;\W*<\/p>$/, '')
          
          # Remove font tags
          self.content = self.content.gsub(/<\/?font[^>]*>/, '')
          self.content = self.content.gsub(/\s?font-family:[^";]*;?/, '')
        end
      end
      
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
          content = self.content.gsub(/(<\/?r:.*?>)/) {|s| CGI.escape(s)}  # Nokogiri pukes on radiant tags, have to comment them out
          doc = Nokogiri::HTML.fragment(content)
          images = doc.css('img')
          images.each do |img|
            width = img.attribute('width').to_s.to_i == 0 ? nil : img.attribute('width').to_s.to_i
            height = img.attribute('height').to_s.to_i == 0 ? nil : img.attribute('height').to_s.to_i
            src = img.attribute('src')
          
            file_id_components = src.to_s.scan(/^\/page_attachments\/?([0-9]{4})\/([0-9]{4}).*?$/).first
            if file_id_components
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
                image = orig_image.create_or_update_thumbnail(orig_image.full_filename, size, size )
              end
              unless image.thumbnail == 'icon'
                image.update_attributes(:filename => "#{File.basename(image.parent.filename, '.*')}_#{image.width}x#{image.height}#{File.extname(image.parent.filename)}", :thumbnail => "#{image.width}x#{image.height}")
              end
          
          
              img.set_attribute('src', image.public_filename)
              img.set_attribute('width', image.width.to_s) unless image.width.blank?
              img.set_attribute('height', image.height.to_s) unless image.height.blank?
          
              # Clean 'style' attribute of all width/height values. Depending on the browser these could get set incorrectly and persist across saves.
              style = img.attribute('style')
              sanitized_style = style.to_s.gsub(/(width|height):[^;]*;?\s?/, '')
              img.set_attribute('style', sanitized_style)
            end
          end
          doc.to_s.gsub(/%3C(%2F)?r%3A(.*?)%3E/) {|s| CGI.unescape(s) } # re-convert <r:whatever> tags
        end
      end
     
      def replace_textile_images
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
    
  end

  def deactivate
  end

end

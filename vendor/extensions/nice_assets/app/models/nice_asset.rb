class NiceAsset < ActiveRecord::Base
  # has_attachment :storage => :s3, :processor => 'ImageScience', :thumbnails => { '100' => '100x100' }
  has_attachment :storage => :file_system, :processor => 'ImageScience', :thumbnails => { '100' => '100x100' }
  # has_attachment :storage => :file_system, :processor => 'MiniMagick', :thumbnails => { '100' => '100x100' }
  # has_attachment :storage => :file_system, :processor => 'ImageScience', :thumbnails => { '300' => '300x300', '100' => '100x100' }
  belongs_to :user, :foreign_key => "created_by"
  has_many :page_assets
  
  ## This is our "has_many" relationship for pages
  ## Written as raw SQL because I couldn't figure out how to get rails to automagically create this statement
  def pages
    Page.find_by_sql(%{SELECT pages.* FROM pages LEFT OUTER JOIN page_assets ON pages.id = page_assets.page_id WHERE ((page_assets.resource_type = 'NiceAsset') AND (page_assets.resource_id = #{self.id}))})
  end
  
  def before_destroy
    PageAsset.destroy_all("resource_type = 'NiceAsset' and resource_id = #{self.id}")
  end
  
  CONTENT_TYPES = {
    'image'   =>  {'regex' => '^image', 'like' => 'image%'},
    'video'   =>  {'regex' => '^video', 'like' => 'video%'},
    'audio'   =>  {'regex' => '^audio', 'like' => 'audio%'},
    'pdf'     =>  {'regex' => 'pdf$', 'like' => '%pdf'},
    'flash'   =>  {'regex' => 'flash$', 'like' => '%flash'},
  }
  
  def thumbnail_public_filename(thumbnail = nil)
    if self.content_type =~ /^(?!image)/ or self.content_type =~ /svg/
      return self.public_filename
    else
      filename = full_filename(thumbnail).gsub %r(^#{Regexp.escape(base_path)}), ''
      if thumbnail?
        return filename
      else
        sections = filename.split('/')
        return sections.join('/')
      end
    end
  end
  
  # get the dimensions for an image based on the maximum side length for that image
  def dimensions(max_size)
    if self.width.nil?
      return nil
    else
      # if self.width < 300 and self.height < 300
        return "#{self.width.to_i}x#{self.height.to_i}"
    #   else
    #   return self.width > self.height ? "#{max_size}x#{((self.height * max_size)/self.width).to_i}" : "#{((self.width * max_size)/self.height).to_i}x#{max_size}"
    # end
    end
  end
  
  # get the parent id of an element; if it has no parent, get it's own id
  def asset_id
    self.parent ? self.parent.id : self.id
  end
  
  # get the basic content type of an asset for regex matching
  def basic_content_type
    types = []
    CONTENT_TYPES.each do |key, value|
      types << value['regex']
    end
    begin
      self.content_type.match(/#{types.join('|')}/)[0]
    rescue
      'other'
    end
  end
  
  # TODO : Not safe from SQL injection attacks, need to escape conditions
  # TODO : Might want to use REGEXP instead of LIKE in these queries on a production database.
  # It may end up being faster, but sqlite3 doesn't seem to support the REGEXP funciton, so 
  # LIKE is used instead
  def self.find_by_content_types(content_types, sort_order = 'created_at desc', current_page = 1)
    conditions_positive, remaining_content_types = [], CONTENT_TYPES.keys
    conditions = []
    if not content_types.nil?
      content_types.each do |type|
        if type != 'other'
          conditions_positive << %{content_type like "#{CONTENT_TYPES[type]['like']}"}
          remaining_content_types.delete(type) 
        end
      end
    
      if !conditions_positive.nil?
        conditions << conditions_positive.join(' or ')
      end
      
      if content_types.include?('other')
        conditions << '(' + remaining_content_types.collect { |type| %{content_type not like "#{CONTENT_TYPES[type]['like']}"} }.join(' and ') + ')'
      end

      if sort_order.nil?
        sort_order = 'created_at desc'
      end

      conditions.delete('')
      conditions.delete('()') # remove empty conditions
      begin
        self.find(:all, :conditions => "parent_id is null and (#{conditions.join(' or ')})", :order => sort_order, :page => {:size => 18, :current => current_page} )
      rescue
      end
    end
  end
  
  # get an image's ratio of width/height
  def ratio
    self.parent ? (self.parent.width.to_f/self.parent.height.to_f) : (self.width.to_f/self.height.to_f)
  end

end

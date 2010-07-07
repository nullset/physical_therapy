module AlternateTitleTags
  include Radiant::Taggable

  class TagError < StandardError; end
  
  desc %{
    Displays a page's alternate title if one is present, otherwise displays the page's title

    *Usage:*
    
    <pre><code><r:alternate_title /></code></pre>
  }
  tag 'alternate_title' do |tag|
    return tag.locals.page.alternate_title unless tag.locals.page.alternate_title.blank?
    return tag.locals.page.title
  end

end
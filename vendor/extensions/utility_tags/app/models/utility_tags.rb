module UtilityTags
  include Radiant::Taggable

  class TagError < StandardError; end
  
  desc %{
    Splits a URL into various sections, delimited by a character. Useful for pulling using as a filter.

    *Usage:*
    
    <pre><code><r:url_section number="number" [separator="character"] /></code></pre>
  }
  tag 'url_section' do |tag|
    raise TagError.new("`url_section' tag must contain a `number' attribute.") unless tag.attr.has_key?('number')
    delimiter = tag.attr.has_key?('separator') ? tag.attr['separator'] : '/'
    url_sertion = tag.locals.page.url.split(delimiter)[tag.attr['number'].to_i + 1]
  end

  desc %{
    Converts a title of a page (that is last name, first name, etc.) into an actual name (first name  last name, etc.)

    *Usage:*
    
    <pre><code><r:title_as_name [separator="character"] /></code></pre>
  }
  tag 'title_as_name' do |tag|
    delimiter = tag.attr.has_key?('separator') ? tag.attr['separator'] : ','
    parts = tag.locals.page.title.split(delimiter)
    title_as_name = "#{parts.delete_at(1)} #{parts.delete_at(0)}, #{parts.join(', ')}"
  end

  desc %{
    Causes the tags referring to a parts's attributes to refer to the current part.
  
    *Usage:*
    
    <pre><code><r:part>...</r:part></code></pre>
  }
  tag 'part' do |tag|
    tag.locals.part = tag.globals.part
    raise tag.inspect
    tag.expand
  end
  
  desc %{
    Gives access to a page's parts.
  
    *Usage:*
    
    <pre><code><r:parts>...</r:parts></code></pre>
  }
  tag 'parts' do |tag|
    tag.locals.parts = tag.locals.page.parts
    tag.expand
  end
  
  tag 'part_content' do |tag|
    part = tag.locals.part
    tag.globals.page.render_snippet(part) # unless part.nil?
  end
  
  
  desc %{
    Cycles through each of the page parts, collects according to "matches" attribute
  
    *Usage:*
    
    <pre><code><r:parts [match="regexp"] [order="name1,name2,..."]>
     ...
    </r:parts>
    </code></pre>
  }
  tag 'parts:names' do |tag|
    match = tag.attr.has_key?('match') ? tag.attr['match'] : '.*'
    order = tag.attr.has_key?('order') ? tag.attr['order'] : nil
    
    order_names = []
    unless order.blank?
      order_names = order.split(/,/).collect {|o| o.strip }
    end
  
    result = []
    parts = tag.locals.parts.find_all {|part| part.name =~ /#{match}/ }
    order_names.each do |name|
      part = parts.detect {|part| part.name == name } unless parts.blank?
      if part
        tag.locals.part = part
        result << tag.expand
        # result << part.content
        parts.delete(part)
      end
    end
    if parts
      parts.each do |part|
        tag.locals.part = part
        result << tag.expand
        # result << part.content
      end
    end
    result
  end
  
end


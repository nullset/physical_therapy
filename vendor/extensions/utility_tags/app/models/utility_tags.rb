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

end

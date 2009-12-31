class ActiveRecord::Base
  def escape_radius_tags(text)
    text.gsub(/(<\/?r:.*?>)/) {|s| CGI.escape(s)}  # Nokogiri pukes on radiant tags, have to comment them out
  end
  
  def unescape_radius_tags(nokogiri_doc)
    nokogiri_doc.to_s.gsub(/%3C(%2F)?r%3A(.*?)%3E/) {|s| CGI.unescape(s) } # re-convert <r:whatever> tags
  end
end

module UtilityTags
  include Radiant::Taggable

  class TagError < StandardError; end
  
  desc %{
    Splits a URL into various sections, delimited by a character. Useful for displaying just part of a URL string.

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
    raise escape_radius_tags(tag.content).inspect
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

  desc %{
    Proceeds only if the page part exists
  
    *Usage:*
    
    <pre><code><r:if_parts match="regexp">
     ...
    </r:if_parts>
    </code></pre>
  }
  tag 'if_parts' do |tag|
    raise TagError.new("`if_parts' tag must contain a `match' attribute.") unless tag.attr.has_key?('match')
    match = tag.attr['match']
    
    parts = tag.locals.page.parts.find_all {|part| part.name =~ /#{match}/ }
    tag.expand if parts.length > 0
  end

  desc %{
    Grabs only a portion of a page part.
  
    *Usage:*
    
    <pre><code><r:excerpt [name="body"] [num="15"] [truncate_string="..."] /></code></pre>
  }
  tag 'excerpt' do |tag|
    name = tag.attr.has_key?('name') ? tag.attr['name'] : 'body'
    num = tag.attr.has_key?('num') ? tag.attr['num'] : 100
    truncate_string = tag.attr.has_key?('truncate_string') ? tag.attr['truncate_string'] : '...'

    page = tag.locals.page
    excerpt = page.part(name).content rescue nil
    if excerpt
      doc = Nokogiri::HTML.fragment(excerpt)
      excerpted_text = doc.css('p')
      excerpted_text.search('img').remove
      unless excerpted_text.blank?
        truncated = excerpted_text.to_s.gsub(/<p>\s*&nbsp;\s*<\/p>/, '').gsub(/<\/?.*?>/, '').gsub(/&amp;/, '&')[0..num.to_i]
        content = unescape_radius_tags("<p>#{truncated}#{truncate_string}</p>")
      end
    end
  end

  tag 'excerpt_image' do |tag|
    page = tag.locals.page
    image = page.part('head_shot').content rescue nil
    if image
      noko_img = Nokogiri::HTML.fragment(image).css('img').first
      img = %{<img src="#{noko_img.attribute('src')}" width="67" alt="#{noko_img.attribute('alt')}" />}
    end
    img
  end
  
  tag 'children:each_if' do |tag|
    raise TagError.new("`children:each_if' tag must contain a `name' attribute.") unless tag.attr.has_key?('name')
    name = tag.attr['name']

    page = tag.locals.page
    raise page.parts.inspect
    
    tag.expand if tag.locals.first_child
  end
  
  
end

def html_truncate(input, num = 15, truncate_string = "...")
	doc = Nokogiri::HTML(input)

	current = doc.children.first
	count = 0

	while true
		# we found a text node
		if current.is_a?(Nokogiri::XML::Text)
			count += current.text.split.length
			# we reached our limit, let's get outta here!
			break if count > num
			previous = current
		end

		if current.children.length > 0
			# this node has children, can't be a text node,
			# lets descend and look for text nodes
			current = current.children.first
		elsif !current.next.nil?
			#this has no children, but has a sibling, let's check it out
			current = current.next
		else 
			# we are the last child, we need to ascend until we are
			# either done or find a sibling to continue on to
			n = current
			while !n.is_a?(Nokogiri::HTML::Document) and n.parent.next.nil?
				n = n.parent
			end

			# we've reached the top and found no more text nodes, break
			if n.is_a?(Nokogiri::HTML::Document)
				break;
			else
				current = n.parent.next
			end
		end
	end

	if count >= num
	  unless count == num
  		new_content = current.text.split

      # If we're here, the last text node we counted eclipsed the number of words
      # that we want, so we need to cut down on words.  The easiest way to think about
      # this is that without this node we'd have fewer words than the limit, so all
      # the previous words plus a limited number of words from this node are needed.
      # We simply need to figure out how many words are needed and grab that many.
      # Then we need to -subtract- an index, because the first word would be index zero.

      # For example, given:
      # <p>Testing this HTML truncater.</p><p>To see if its working.</p>
      # Let's say I want 6 words.  The correct returned string would be:
      # <p>Testing this HTML truncater.</p><p>To see...</p>
      # All the words in both paragraphs = 9
      # The last paragraph is the one that breaks the limit.  How many words would we
      # have without it? 4.  But we want up to 6, so we might as well get that many.
      # 6 - 4 = 2, so we get 2 words from this node, but words #1-2 are indices #0-1, so
      # we subtract 1.  If this gives us -1, we want nothing from this node. So go back to
      # the previous node instead.
      index = num-(count-new_content.length)-1
      if index >= 0
        new_content = new_content[0..index]
  		  current.content = new_content.join(' ') + truncate_string
		  else
		    current = previous
		    current.content = current.content + truncate_string
	    end
	  end

		# remove everything else
		while !current.is_a?(Nokogiri::HTML::Document)
			while !current.next.nil?
				current.next.remove
			end
			current = current.parent
		end
	end

	# now we grab the html and not the text.
	# we do first because nokogiri adds html and body tags
	# which we don't want
	doc.root.children.first.inner_html
end


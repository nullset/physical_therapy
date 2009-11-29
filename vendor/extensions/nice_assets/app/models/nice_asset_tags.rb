module NiceAssetTags
  include Radiant::Taggable
  
  class TagError < StandardError; end
  
  # desc %{
  #   Renders an image tag to display an image.
  # 
  #   *Usage:* 
  #   <div><pre><code><r:image src="" [width="" height="" title="" alt=""] /></code></pre></div>
  #   
  #   Note: Attributes inside the brackets are optional
  # }
  tag 'image' do |tag|
    page = tag.locals.page
    attributes = !tag.attr.include?('alt') ? 'alt="" ' : ''          # ensures that the alt attribute is not left out as it is a required attribute in XHTML 1.0 strict
    attributes += tag.attr.collect {|k,v| %{#{k}="#{v}"}}.join(' ')
    %{<img #{attributes} />}
  end
  
 
  # desc %{
  #   Renders an object tag to display a svg file.
  # 
  #   *Usage:* 
  #   <div><pre><code><r:svg src="" [width="" height="" title=""] /></code></pre>
  #   <pre><code><r:svg src="" [width="" height="" title=""]>ALTERNATE CONTENT</r:svg></code></pre></div>
  #   
  #   Note: Attributes inside the brackets are optional
  # }
  tag 'svg' do |tag|
    page = tag.locals.page
    attributes = tag.attr
    src = attributes['src']
    width = attributes['width']
    height = attributes['height']
    %{<object data="#{src}" width="#{width}" height="#{height}" type="image/svg+xml"></object>}
  end


  # desc %{
  #   Renders the code required to embed a flash movie into a page.
  # 
  #   *Usage:* 
  #   <div><pre><code><r:flash src="" [width="" height="" quality="(high|medium|low)"] /></code></pre>
  #   <pre><code><r:flash src="" [width="" height="" quality="(high|medium|low)"]>ALTERNATE CONTENT</r:flash></code></pre></div>
  #   
  #   Note: Attributes inside the brackets are optional
  # }
  tag 'flash' do |tag|
    page = tag.locals.page
    attributes = tag.attr
    src = attributes['src']
    quality = attributes.include?('quality') ? attributes['quality'] : 'high'
    width = attributes.include?('width') ? attributes['width'] : 300
    height = attributes.include?('height') ? attributes['height'] : 300
    background = attributes.include?('background') ? attributes['background'] : '#ffffff'
    
    %{<object type="application/x-shockwave-flash" data="/images/extensions/nice_assets/container.swf?path=#{src}" width="#{width}" height="#{height}">
  <param name="movie" value="/images/extensions/nice_assets/container.swf?path=#{src}" />
  <param name="bgcolor" value="#{background}" />
  <param name="quality" value="#{quality}" />
  FLASH plugin not installed
</object>}
  end
  
  # desc %{
  #   Renders the code required to embed a video file into a page.
  # 
  #   *Usage:* 
  #   <div><pre><code><r:video src="" [width="" height="" controls="(true|false)" autoplay="(true|false)"] /></code></pre>
  #   <pre><code><r:video src="" [width="" height="" controls="(true|false)" autoplay="(true|false)"]>ALTERNATE CONTENT</r:video></code></pre></div>
  #   
  #   Note: Attributes inside the brackets are optional
  # }
  tag 'video' do |tag|
    page = tag.locals.page
    attributes = tag.attr
    src = attributes['src']
    width = attributes.include?('width') ? attributes['width'] : 300
    height = attributes.include?('height') ? attributes['height'] : 300
    controls = attributes.include?('controls') ? attributes['controls'] : true
    autoplay = attributes.include?('autoplay') ? attributes['autoplay'] : false
    extension = File.extname(attributes['src'])[/([^.].*)/]   # get just the extension name
    
    
    if extension == 'mov'
      # Quicktime movie
      # XHTML compliant code from http://alistapart.com/articles/byebyeembed
      return %{<object classid="clsid:02BF25D5-8C17-4B23-BC80-D3488ABDDC6B" codebase="http://www.apple.com/qtactivex/qtplugin.cab" width="#{width}" height="#{height}">
  <param name="src" value="#{src}" />
  <param name="controller" value="#{controls}" />
  <param name="autoplay" value="#{autoplay}" />
  <!--[if !IE]>-->
    <object type="video/quicktime" data="#{src}" width="#{width}" height="#{height}">
      <param name="autoplay" value="#{autoplay}" />
      <param name="controller" value="#{controls}" />
      <param name="scale" value="tofit" />
    </object>
  <!--<![endif]-->
</object>}
    elsif extension == 'wmv'
      # Windows Media Video
      # XHTML compliant code from http://alistapart.com/articles/byebyeembed
      return %{<object classid="CLSID:6BF52A52-394A-11d3-B153-00C04F79FAA6" id="player" width="#{width}" height="#{height}">
  <param name="url" value="#{src}" />
  <param name="src" value="#{src}" />
  <param name="showcontrols" value="#{controls}" />
  <param name="autostart" value="#{autoplay}" />
  <!--[if !IE]>-->
    <object type="video/x-ms-wmv" data="#{src}" width="#{width}" height="#{height}">
      <param name="src" value="#{src}" />
      <param name="autostart" value="#{autoplay}" />
      <param name="controller" value="#{controls}" />
    </object>
  <!--<![endif]-->
</object>}
    end
  end
  
end
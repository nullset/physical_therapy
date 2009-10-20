require_dependency 'application_controller'

class TinyMceFilterExtension < Radiant::Extension
  version "0.8"
  description "Provides WYSIWYG (What You See Is What You Get) rich text editing capabilities."
  url "http://blog.brandalism.com/tinymce"

  define_routes do |map|
    # map.connect 'admin/tinymce/:action', :controller => 'admin/tinymce'
  end
  
  def activate
    # admin.tabs.add "Tinymce Filter", "/admin/tinymce_filter", :after => "Layouts", :visibility => [:all]
    raise "The Shards extension is required and must be loaded first!" unless defined?(admin.page)
    TinyMceFilter
    admin.page.edit.add :main, 'tiny_mce_includes', :before => 'edit_header'
    admin.page.edit.add :part_controls, 'tiny_mce_part'
    admin.snippet.edit.add :main, 'tiny_mce_includes', :before => 'edit_header'  
    admin.snippet.edit.add :main, 'tiny_mce_part', :after => 'edit_form'
  end
  
  def deactivate
    # admin.tabs.remove "Tinymce Filter"
  end
    
end
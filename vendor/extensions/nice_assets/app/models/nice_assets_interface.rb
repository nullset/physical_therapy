module NiceAssetsInterface
  def self.included(base)
    base.class_eval {
      before_filter :add_nice_assets_partials,
                    :only => [:edit, :new]
      include InstanceMethods
    }
  end

  module InstanceMethods
    def add_nice_assets_partials
      @buttons_partials ||= []
      @buttons_partials << "nice_assets_box"
      # include_javascript 'admin/dragdrop'
      # include_javascript 'admin/page_attachments'
      # include_stylesheet 'admin/page_attachments'

      include_javascript "admin/jquery-1.3.2.min"
      include_javascript "admin/swfobject"
      include_javascript "extensions/nice_assets/jquery.uploadify.v2.1.0.min"
      include_javascript "admin/jquery_no_conflict"
      # include_javascript "extensions/nice_assets/uploadify_setup"
    end
  end
end

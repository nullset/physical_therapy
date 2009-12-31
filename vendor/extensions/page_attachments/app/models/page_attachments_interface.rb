module PageAttachmentsInterface
  def self.included(base)
    base.class_eval {
      before_filter :add_page_attachment_partials,
                    :only => [:edit, :new]
      include InstanceMethods
    }
  end

  module InstanceMethods
    def add_page_attachment_partials
      @buttons_partials ||= []

      # @buttons_partials << "nice_assets_box"
      include_javascript 'admin/jquery-1.3.2.min'
      include_javascript 'admin/jquery_no_conflict'
      include_javascript 'admin/swfobject'
      include_javascript 'admin/jquery.uploadify.v2.1.0.min'
      include_javascript 'extensions/nice_assets/jquery.simplemodal-1.3.3.min.js'
      include_stylesheet 'admin/nice_assets'

      # @buttons_partials << "attachments_box"
      # include_javascript 'admin/dragdrop'
      # include_javascript 'admin/page_attachments'
      # include_stylesheet 'admin/page_attachments'
    end
  end
end

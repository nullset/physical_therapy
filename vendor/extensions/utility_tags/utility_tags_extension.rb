class UtilityTagsExtension < Radiant::Extension
  version "1.0"
  description ""
  url ""

  def activate
    Page.class_eval {
      include UtilityTags
    }
  end

  def deactivate
  end

end

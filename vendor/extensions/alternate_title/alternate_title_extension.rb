class AlternateTitleExtension < Radiant::Extension

  def activate
    if admin.pages && admin.pages.edit && admin.pages.edit.extended_metadata
      admin.pages.edit.add :extended_metadata, 'alternate_page_title'
    end
    
    Page.class_eval {
      include AlternateTitleTags
    }
    
  end
  
end
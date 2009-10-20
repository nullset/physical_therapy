namespace :radiant do
  namespace :extensions do
    namespace :tiny_mce_editor_filter do
      
      desc "Runs the migration of the Wym Editor Filter extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          TinyMceEditorFilterExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          TinyMceEditorFilterExtension.migrator.migrate
        end
      end

      desc "Copy needed files to public dir"
      task :install => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        Dir[TinyMceEditorFilterExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(TinyMceEditorFilterExtension.root, '')
          directory = File.dirname(path)
          puts "Copying #{path}..."
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end
      
      desc "Update public files except tiny_mce.css"
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        Dir[TinyMceEditorFilterExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          next if file =~ /tiny_mce\.css/
          path = file.sub(TinyMceEditorFilterExtension.root, '')
          directory = File.dirname(path)
          puts "Copying #{path}..."
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end
      

    end
  end
end
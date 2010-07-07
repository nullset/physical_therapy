namespace :radiant do
  namespace :extensions do
    namespace :alternate_title do
      
      desc "Runs the migration of the AlternateTitle extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          AlternateTitleExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          AlternateTitleExtension.migrator.migrate
        end
      end
      
    end
  end
end

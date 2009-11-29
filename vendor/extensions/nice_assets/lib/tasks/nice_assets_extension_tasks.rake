namespace :radiant do
  namespace :extensions do
    namespace :nice_assets do
      
      desc "Runs the migration of the Nice Assets extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          NiceAssetExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          NiceAssetExtension.migrator.migrate
        end
      end
    
    end
  end
end
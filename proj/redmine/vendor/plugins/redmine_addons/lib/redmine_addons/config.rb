module RedmineAddons
  
  class Config
    @@available_settings = nil
  
    def self.settings
      @@available_settings ||= YAML::load(File.open("#{Rails.root}/vendor/plugins/redmine_addons/config/redmine_specific_addons.yml"))
    end
  end
  
end
require 'byebug' if ENV['RACK_ENV'] == 'development'
require 'pry' if ENV['RACK_ENV'] == 'development'

require_relative 'container'

Main::Container.finalize! do |container|
  # Boot the app config before everything else
  container.boot! :config
end

app_paths = Pathname(__dir__).join('..', 'apps').realpath.join('*')
Dir[app_paths].each do |f|
  require "#{f}/system/boot"
end

require_relative 'application'

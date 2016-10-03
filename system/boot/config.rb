Main::Container.finalize(:config) do |container|
  require 'main/config'
  container.register 'config', Main::Config.load(container.root, 'application', container.config.env)
end

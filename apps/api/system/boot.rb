require_relative 'container'

Api::Container.finalize! do |container|
  # require "main/enqueue"
  # container.register :enqueue, Main::Enqueue.new
end

require_relative 'application'

# Api::Container.require "transactions/**/*.rb"

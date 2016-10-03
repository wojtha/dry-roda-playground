require 'roda'

module Main
  class Application < Roda

    plugin :static,
      ['/assets', '/robots.txt', '/favicon.ico', '/apple-touch-icon.png'],
      header_rules: [
        [:all, { 'Cache-Control' => 'public, max-age=86400' }],
        ['/assets', { 'Cache-Control' => 'public, max-age=31536000' }]
      ]

    plugin :error_handler
    plugin :run_append_slash # Makes r.run use "/" instead of "" for app's PATH_INFO

    route do |r|
      # r.on "admin" do
      #   r.run Admin::Application.freeze.app
      # end

      # r.run Main::Application.freeze.app
      r.root do
        r.redirect '/hello'
      end

      r.get 'hello' do
        "Hello world!"
      end

      r.on 'api' do
        r.run Api::Application.freeze.app
      end
    end

    error do |e|
      # handle error
      raise e
    end
  end
end

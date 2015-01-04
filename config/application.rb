require 'rubygems'
require 'bundler/setup'

require 'erb'
require 'pathname'
require 'yaml'

APP_ENV = ENV['APP_ENV'] || :development
Bundler.require(:default, APP_ENV)

#=============================================================================#
# Application setup:
# - (1) root: absolute path to root of the repository
# - (2) env: see also `config/application.yml` (which is excluded from git)
# - (3) config: defined through `config/config.yml`
# - (4) autoload path
# - (3) initializers
#=============================================================================#
module Application
  class << self
    attr_accessor :root
    attr_accessor :config
  end
end

begin
  # (1) root
  Application.root = Pathname.new(File.expand_path('../../.', __FILE__))

  # (2) env variables can be sourced in application.yml (development only)
  if File.exist?(Application.root.join('config', 'application.yml'))
    YAML.load(
      ERB.new(
        File.read(
          Application.root.join('config', 'application.yml')
        )
      ).result
    ).each do |key, value|
      ENV[key] = value.to_s unless ENV.key?(key)
    end
  end

  # (3) set `Application.config` equal to `config/config.yml` file content
  config_path = Application.root.join('config', 'config.yml')
  config = {}
  if config_path.exist?
    config = YAML.load(
      ERB.new(
        File.read(config_path)
      ).result
    )
  end
  Application.config = config

  # (3) autoload path completion:
  # - [app,lib] (reverse order for priority)
  # - all models subdirs
  %w(app lib).reverse.each do |path|
    $LOAD_PATH.unshift(Application.root.join(path))
  end

  Dir["#{Application.root.join('app/models')}/**/"].each do |dir|
    $LOAD_PATH.unshift dir[0...-1]
  end

  # (4) require all initializers
  Dir[Application.root.join('config', 'initializers', '*.rb')].each do |file|
    require file
  end

end

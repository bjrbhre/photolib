require 'json'

namespace :setup do
  desc 'Init application (verbose: display application config)'
  task :application, [:verbose] do |t, params|
    require File.expand_path('../../../config/application.rb', __FILE__)
    if params[:verbose] && params[:verbose].downcase == 'verbose'
      Utils.create_logger(t).info(JSON.pretty_generate(Application.config))
    end
  end
end

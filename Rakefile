require 'rake'
require 'json'

# load tasks in /lib/**/tasks/
Dir[File.expand_path('../lib/**/tasks/*.rake', __FILE__)].each do |file|
  import file
end

desc 'Init application environment and display Application.config if verbose'
task :environment, [:verbose] do |_, params|
  require File.expand_path('../config/environment.rb', __FILE__)
  if params[:verbose] && params[:verbose].downcase == 'verbose'
    puts JSON.pretty_generate(Application.config)
  end
end

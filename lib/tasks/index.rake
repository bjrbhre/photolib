namespace :index do
  desc 'Index all pictures located under root path'
  task :pictures, [:root_path, :rebuild] => 'setup:application' do |t, params|
    require 'jobs/pictures_indexer'
    Utils.create_logger(t).info("launching job with params #{params}")
    Jobs::PicturesIndexer.new.perform(params)
  end
end

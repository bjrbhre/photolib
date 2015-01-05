namespace :import do
  desc 'Index all pictures located under root path'
  task :pictures, [:rebuild] => 'setup:application' do |t, params|
    require 'jobs/pictures_importer'
    Utils.create_logger(t).info("launching job with params #{params}")
    Jobs::PicturesImporter.new.perform(params)
  end
end

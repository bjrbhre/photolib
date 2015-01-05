namespace :db do
  namespace :mongoid do
    desc 'Create the indexes defined on your mongoid models'
    task create_indexes: 'setup:application' do |t|
      logger = Utils.create_logger(t)
      MODELS.each do |model|
        # copy / paste from Rails::Mongoid::create_indexes
        next if model.index_options.empty?
        if model.embedded?
          logger.info("MONGOID: Index ignored on embedded #{model}")
          nil
        else
          model.create_indexes
          logger.info("MONGOID: Created indexes on #{model}:")
          model.index_options.each_pair do |index, options|
            logger.info("MONGOID: Index: #{index}, Options: #{options}")
          end
          model
        end
      end
    end # task :create_indexes
  end # namespace :mongoid
end # namespace :db

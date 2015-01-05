require 'utils'

begin
  base_models = Dir.glob("#{Application.root}/app/models/**/*_base.rb")
  base_models.each do |file|
    require file
  end

  Dir.glob("#{Application.root}/app/models/**/*.rb").each do |file|
    require file unless base_models.include?(file)
  end

  MODELS = [IndexedPicture, ImportedPicture]
end

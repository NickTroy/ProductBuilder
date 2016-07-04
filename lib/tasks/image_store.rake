namespace :image_store do
  desc "Move Images to Azure Cloud"
  task move_to_azure: :environment do
    include ThreeSixtyImagesHelper
    mv_images_to_azure
  end
end

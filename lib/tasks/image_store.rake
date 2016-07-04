namespace :image_store do
  desc "Move images from filesystem to Azure Cloud."
  task mv_local_to_azure: :environment do
    include ThreeSixtyImagesHelper
    mv_images_to_azure
  end

end

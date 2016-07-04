module ThreeSixtyImagesHelper
    
  def mv_images_to_azure
    tsi = ThreeSixtyImage.all
    tsi.each do |t|
  
      variant_images = t.variant_images
      variant_images.each do |vi|
        if vi.image.exists?
          vi.azure_image =  vi.image
          vi.save
        end
      end
      
      plane_images = t.plane_images
      plane_images.each do |pi|
        if pi.image.exists?
          pi.azure_image = pi.image
          pi.azure_big_image = pi.image
          pi.save
        end
      end
  
    end
  end  

    
end

module ThreeSixtyImagesHelper
    
  def mv_images_to_azure
    tsi = ThreeSixtyImage.all
    puts "Start moving " + tsi.length.to_s + " three_sixty_images"
    tsi.each_with_index do |t, tsi_index|
      variant_images = t.variant_images
      puts "Start moving " + tsi_index.to_s + " three sixty image."
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
    puts "All done."
  end 
end

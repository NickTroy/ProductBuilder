module ThreeSixtyImagesHelper
    
  def mv_images_to_azure
    tsi = ThreeSixtyImage.all
    puts "Begin moving " + tsi.length.to_s + " three_sixty_images"
    tsi.each_with_index do |t, tsi_index|
      variant_images = t.variant_images
      puts "Proceed " + tsi_index.to_s + " three sixty image."
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
    
    product_images = ProductImage.all
    puts "Begin moving a product images to Azure Cloud"
    product_images.each_with_index do |image|
      if image.exists?
        image.azure_image = image.image
        image.save
      end
    end
    
    puts "All done."
  end 
end

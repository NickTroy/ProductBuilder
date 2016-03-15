class PlaneImage < ActiveRecord::Base
  belongs_to :three_sixty_image
   
  has_attached_file :image,
      path: ":rails_root/public/system/three_sixty_images/:three_sixty_image_id/:filename",
      url: "/system/three_sixty_images/:three_sixty_image_id/:filename"
      
      
  has_attached_file :big_image,
      path: ":rails_root/public/system/three_sixty_images/:three_sixty_image_id/big_images/:filename",
      url: "/system/three_sixty_images/:three_sixty_image_id/big_images/:filename",
      :styles => { :big => "3500x3500" }, :whiny => true

   Paperclip.interpolates :three_sixty_image_id do |attachment, style|
      attachment.instance.three_sixty_image_id
   end
   


  validates_attachment  :image,
                        #:presence => true,
                        :content_type => { :content_type => /\Aimage\/.*\Z/ },
                        :size => { :less_than => 1.megabyte }
  
end
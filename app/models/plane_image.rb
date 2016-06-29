class PlaneImage < ActiveRecord::Base
  belongs_to :three_sixty_image
   
  has_attached_file :image,
      path: ":class/:attachment/:three_sixty_image_id/:filename"
     
      
      
  has_attached_file :big_image,
      path: ":class/images/:three_sixty_image_id/:attachment/:filename",
      :styles => { :original => "1500x1500" }, :whiny => true

   Paperclip.interpolates :three_sixty_image_id do |attachment, style|
      attachment.instance.three_sixty_image_id
   end
   


  validates_attachment  :image,
                        #:presence => true,
                        :content_type => { :content_type => /\Aimage\/.*\Z/ },
                        :size => { :less_than => 1.megabyte }
  
  def image_from_url url
    self.image = URI.parse(url)
    self.big_image = URI.parse(url)
  end
  
end

class PlaneImage < ActiveRecord::Base
  belongs_to :three_sixty_image
   
  has_attached_file :image,
      path: ":rails_root/public/system/three_sixty_images/:three_sixty_image_id/:filename",
      url: "/system/three_sixty_images/:three_sixty_image_id/:filename"
      
      
  has_attached_file :big_image,
      path: ":rails_root/public/system/three_sixty_images/:three_sixty_image_id/big_images/:filename",
      url: "/system/three_sixty_images/:three_sixty_image_id/big_images/:filename",
      :styles => { :big => "1500x1500" }, :whiny => true

  has_attached_file :azure_image,
                    :storage => :azure_storage,
                    :url => ':azure_path_url',
                    :path => ":class/:attachment/:three_sixty_image_id/:filename",
                    :azure_credentials => {
                      account_name: Rails.application.secrets.account_name,
                      access_key:   Rails.application.secrets.access_key,
                      azure_container: Rails.application.secrets.azure_container
                    }
  has_attached_file :azure_big_image,
                    :storage => :azure_storage,
                    :url => ':azure_path_url',
                    :path => ":class/azure_images/:three_sixty_image_id/:attachment/:filename",
                    :azure_credentials => {
                      account_name: Rails.application.secrets.account_name,
                      access_key:   Rails.application.secrets.access_key,
                      azure_container: Rails.application.secrets.azure_container
                    },
                    :styles => { :original => "1500x1500" }, 
                    :whiny => true    
      

   Paperclip.interpolates :three_sixty_image_id do |attachment, style|
      attachment.instance.three_sixty_image_id
   end
   


  validates_attachment  :image,
                        :content_type => { :content_type => /\Aimage\/.*\Z/ },
                        :size => { :less_than => 1.megabyte }
  validates_attachment  :azure_image,
                        :content_type => { :content_type => /\Aimage\/.*\Z/ },
                        :size => { :less_than => 1.megabyte }
  
  def image_from_url url
    parsed_uri = URI.parse(url)
    self.image = parsed_uri
    self.big_image = parsed_uri
  end
  
  def azure_image_from_url url
    parsed_uri = URI.parse(url)
    self.azure_image = parsed_uri
    self.azure_big_image = parsed_uri
  end
  
end

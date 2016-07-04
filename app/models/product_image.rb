class ProductImage < ActiveRecord::Base
  #has_many :variants, dependent: :nullify
  
  has_attached_file :image, :styles => { :medium => "300x300>",:thumb => "100x100>" }
  has_attached_file :azure_image,
                    :storage => :azure_storage,
                    :url => ':azure_path_url',
                    :path => ":class/:attachment/:id/:style/:filename",
                    :azure_credentials => {
                      account_name: Rails.application.secrets.account_name,
                      access_key:   Rails.application.secrets.access_key,
                      azure_container: Rails.application.secrets.azure_container
                    },
                    :styles => { :medium => "300x300>",:thumb => "100x100>" }
                    
  validates_attachment 	:image, 
				:content_type => { :content_type => /\Aimage\/.*\Z/ },
				:size => { :less_than => 1.megabyte }
	validates_attachment 	:azure_image, 
				:content_type => { :content_type => /\Aimage\/.*\Z/ },
				:size => { :less_than => 1.megabyte }			
				
end

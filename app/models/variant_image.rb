class VariantImage < ActiveRecord::Base
  belongs_to :variant
  before_destroy :update_main_image
  has_attached_file :image, :styles => { :medium => "300x300>",:thumb => "100x100>" }
                  	
  validates_attachment 	:image, 
                        #:presence => true,
                        :content_type => { :content_type => /\Aimage\/.*\Z/ },
                        :size => { :less_than => 1.megabyte }

  private
  
  def update_main_image
    if self.id == self.variant.main_image_id
      if self.variant.variant_images.count == 1
        self.variant.update_attributes(main_image_id: nil)
      else
        @images_ids = []
        self.variant.variant_images.each do |img|
          @images_ids.push img.id
        end
        @images_ids.delete(self.id)
        self.variant.update_attributes(main_image_id: @images_ids.first)
      end
    end
  end
end


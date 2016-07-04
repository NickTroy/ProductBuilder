class VariantImage < ActiveRecord::Base
  require 'open-uri'
  
  belongs_to :three_sixty_image
  before_destroy :update_main_image_id
  after_destroy :update_main_product_image
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
                        
                        
  def image_from_url url
    self.image = URI.parse(url)
  end
  
  def azure_image_from_url url
    self.azure_image = URI.parse(url)
  end
  
  private
  
  def update_main_image_id
    if self.id == self.three_sixty_image.main_image_id
      if self.three_sixty_image.variant_images.count == 1
        self.three_sixty_image.update_attributes(main_image_id: nil)
      else
        @images_ids = []
        self.three_sixty_image.variant_images.each do |img|
          @images_ids.push img.id
        end
        @images_ids.delete(self.id)
        self.three_sixty_image.update_attributes(main_image_id: @images_ids.first)
      end
    end
  end

  def update_main_product_image
    if self.three_sixty_image.plane_images.empty?
      #@product_variants = Variant.where(:product_id => self.variant.product_id)
      self.three_sixty_image.variants.each do |variant|
        if variant.main_variant
          update_product_image(self.three_sixty_image.main_image_id, variant.id)
        end
      end
    end
  end
  
  def update_product_image main_image_id, variant_id
    @variant = Variant.find(variant_id)
    @product = ShopifyAPI::Product.find(@variant.product_id)
    unless main_image_id.nil? or main_image_id == ""
      @main_variant_image = VariantImage.find(main_image_id)
      @shopify_product_image = @product.images.first
      unless @shopify_product_image.nil?
        @shopify_product_image.destroy
      end
      @shopify_product_image = ShopifyAPI::Image.new(:product_id => @product.id, :position => 1)
      @shopify_product_image.src = 'https://productbuilder.arborgentry.com/' + @main_variant_image.image.url
      @shopify_product_image.save
    end
    if main_image_id.nil? or main_image_id == ""
      unless @product.images.first.nil?
        @product.images.first.destroy
      end
    end
  end
end


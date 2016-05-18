class VariantImage < ActiveRecord::Base
  require 'open-uri'
  
  belongs_to :variant
  before_destroy :update_main_image_id
  after_destroy :update_main_product_image
  has_attached_file :image, :styles => { :medium => "300x300>",:thumb => "100x100>" }
                  	
  validates_attachment 	:image, 
                        #:presence => true,
                        :content_type => { :content_type => /\Aimage\/.*\Z/ },
                        :size => { :less_than => 1.megabyte }

  def image_from_url url
    url.gsub!(' ','');
    self.image = URI.parse(url)
  end
  
  private
  
  def update_main_image_id
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

  def update_main_product_image
    if self.variant.three_sixty_image.nil?
      #@product_variants = Variant.where(:product_id => self.variant.product_id)
      if self.variant.main_variant
        update_product_image(self.variant.main_image_id)
      end
    end
  end
  
  def update_product_image main_image_id
    @product = ShopifyAPI::Product.find(self.variant.product_id)
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


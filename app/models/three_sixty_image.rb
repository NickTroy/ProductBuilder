class ThreeSixtyImage < ActiveRecord::Base
  belongs_to :variant
  has_many :plane_images, dependent: :destroy
  after_save :update_product_image 
  after_destroy :update_product_image_with_variant_image
  
  private
  
  def update_product_image
    @product = ShopifyAPI::Product.find(self.variant.product_id)
    unless self.plane_images.empty? 
      @product_variants = Variant.where(:product_id => @product.id)
      if self.variant.id == @product_variants.first.id     
        @first_plane_image = self.plane_images.first
        @shopify_product_image = @product.images.first
        unless @shopify_product_image.nil?
          @shopify_product_image.destroy
        end
        @shopify_product_image = ShopifyAPI::Image.new(:product_id => @product.id)
        @shopify_product_image.src = 'https://productbuilder.arborgentry.com/' + @first_plane_image.image.url
        @shopify_product_image.save
      end
    end
  end
  
  def update_product_image_with_variant_image
    @product = ShopifyAPI::Product.find(self.variant.product_id)
    @main_variant_image = VariantImage.find(self.variant.main_image_id) unless self.variant.main_image_id.nil?
    unless @main_variant_image.nil?
      @product_variants = Variant.where(:product_id => @product.id)
      if self.variant.id == @product_variants.first.id
        @shopify_product_image = @product.images.first
        unless @shopify_product_image.nil?
          @shopify_product_image.destroy
        end
        @shopify_product_image = ShopifyAPI::Image.new(:product_id => @product.id)
        @shopify_product_image.src = 'https://productbuilder.arborgentry.com/' + @main_variant_image.image.url
        @shopify_product_image.save
      end
    end
    
    if @main_variant_image.nil?  
      unless @product.images.first.nil?
        @product.images.first.destroy
      end
    end
  end
end

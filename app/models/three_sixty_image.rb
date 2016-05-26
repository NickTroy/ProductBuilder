class ThreeSixtyImage < ActiveRecord::Base
  has_many :variants, dependent: :nullify
  has_many :plane_images, dependent: :destroy
  has_many :variant_images, dependent: :destroy
  after_save :update_product_image 
  #after_destroy :update_product_image_with_variant_image
  
  private
  
  def update_product_image
    self.variants.each do |variant|
      @product = ShopifyAPI::Product.find(variant.product_id)
      unless self.plane_images.empty? 
        if variant.main_variant   
          @first_plane_image = self.plane_images.first
          @shopify_product_image = @product.images.first
          unless @shopify_product_image.nil?
            @shopify_product_image.destroy
          end
          @shopify_product_image = ShopifyAPI::Image.new(:product_id => @product.id, :position => 1)
          @shopify_product_image.src = 'https://productbuilder.arborgentry.com/' + @first_plane_image.image.url
          @shopify_product_image.save
        end
      end
    end
  end
  
  def update_product_image_with_variant_image
    self.variants.each do |variant|
      @product = ShopifyAPI::Product.find(variant.product_id)
      @main_variant_image = VariantImage.find(variant.main_image_id) unless variant.main_image_id.nil?
      @shopify_product_image = @product.images.first
      unless @shopify_product_image.nil?
        @shopify_product_image.destroy
      end
      unless @main_variant_image.nil?
        if variant.main_variant
          @shopify_product_image = ShopifyAPI::Image.new(:product_id => @product.id, :position => 1)
          @shopify_product_image.src = 'https://productbuilder.arborgentry.com/' + @main_variant_image.image.url
          @shopify_product_image.save
        end
      end
    end
  end
end

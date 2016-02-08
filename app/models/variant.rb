class Variant < ActiveRecord::Base
  has_many :variants_option_values, dependent: :nullify
  has_many :option_values, through: :variants_option_values, dependent: :destroy
  #has_and_belongs_to_many :option_values
  belongs_to :product_image
  has_many :variant_images, dependent: :nullify
  has_one :three_sixty_image, dependent: :destroy
  after_update :update_product_image_with_variant_image
  private
  
  def update_product_image_with_variant_image
    if self.three_sixty_image.nil?
      update_product_image(self.main_image_id)
    end
  end

  def update_product_image main_image_id
    unless main_image_id.nil? or main_image_id == ""
      @product = ShopifyAPI::Product.find(self.product_id)
      @main_variant_image = VariantImage.find(main_image_id)
      @shopify_product_image = @product.images.first
      unless @shopify_product_image.nil?
        @shopify_product_image.destroy
      end
      @shopify_product_image = ShopifyAPI::Image.new(:product_id => @product.id)
      @shopify_product_image.src = 'https://productbuilder.arborgentry.com/' + @main_variant_image.image.url
      @shopify_product_image.save
    end
  end
end

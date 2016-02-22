class Variant < ActiveRecord::Base
  has_many :variants_option_values, dependent: :nullify
  has_many :option_values, through: :variants_option_values, dependent: :destroy
  #has_and_belongs_to_many :option_values
  belongs_to :product_image
  has_many :variant_images, dependent: :destroy
  has_one :three_sixty_image, dependent: :destroy
  after_save :update_product_image_with_variant_image
  before_destroy :update_product_image_with_next_variant_image

  private
  
  def update_product_image_with_variant_image
    if self.three_sixty_image.nil?
      @product_variants = Variant.where(:product_id => self.product_id)
      if self.id == @product_variants.first.id
        update_product_image(self.main_image_id)
      end
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
  
  def update_product_image_with_next_variant_image
    @product_variants = Variant.where(:product_id => self.product_id)
    if self.id == @product_variants.first.id
      @next_variant = @product_variants[1]
      unless @next_variant.nil?
        if @next_variant.three_sixty_image.nil?
          update_product_image(@next_variant.main_image_id) unless @next_variant.nil? or @next_variant.main_image_id.nil?
        else
          @first_plane_image = @next_variant.three_sixty_image.plane_images.first
          @product = ShopifyAPI::Product.find(self.product_id)
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
  end
end

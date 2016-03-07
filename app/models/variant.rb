class Variant < ActiveRecord::Base
  has_many :variants_option_values, dependent: :nullify
  has_many :option_values, through: :variants_option_values, dependent: :destroy
  belongs_to :product_image
  has_many :variant_images, dependent: :destroy
  has_one :three_sixty_image, dependent: :destroy
  after_update :update_product_image_with_variant_image
  before_destroy :destroy_product_image

  private
  
  def update_product_image_with_variant_image
    if self.three_sixty_image.nil?
      @product_variants = Variant.where(:product_id => self.product_id)
      if self.main_variant
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
  
  def destroy_product_image
    if self.main_variant
      @product = ShopifyAPI::Product.find(self.product_id)
      @shopify_product_image = @product.images.first
      unless @shopify_product_image.nil?
        @shopify_product_image.destroy
      end
    end
  end
  
  private
  
  def recreate_pseudo_product
    @pseudo_product_title = ""
    @variant.option_values.each do |option_value|
      @pseudo_product_title += " #{option_value.option.name} : #{option_value.value}"
    end
    @pseudo_product = ShopifyAPI::Product.create(title: "#{@pseudo_product_title}")
    @pseudo_product_variant = @pseudo_product.variants.first
    @pseudo_product_variant.update_attributes(:option1 => @pseudo_product_title)
    @variant.update_attributes(:pseudo_product_id => @pseudo_product.id, 
                               :pseudo_product_variant_id => @pseudo_product_variant.id)
  end
end

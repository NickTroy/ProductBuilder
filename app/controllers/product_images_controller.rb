class ProductImagesController < AuthenticatedController
  skip_before_action :verify_authenticity_token
  
  def create
    @product = ShopifyAPI::Product.find(params[:product_id])
    @image = ProductImage.new(image_params)
    if @image.save
      @first_image = ProductImage.where(:product_id => params[:product_id]).first
      @shopify_product_image = @product.images.first
      unless @shopify_product_image.nil?
        @shopify_product_image.destroy
      end
      @shopify_product_image = ShopifyAPI::Image.new(:product_id => @product.id)
      @shopify_product_image.src = URI.join(request.url, @first_image.image.url).to_s 
      if @shopify_product_image.save  
        render json: { message: "success", imageID: @image.id }, :status => 200
      else
        render json: { message: "failed" }, :status => 500
      end
    else 
      render json: { message: "failed" }, :status => 500
    end
  
  end
  
  def destroy
    @image = ProductImage.find(params[:id])
    @product = ShopifyAPI::Product.find(@image.product_id)
    @product_images = ProductImage.where(:product_id => @image.product_id)
    if @product_images.count == 1
      @shopify_product_image = @product.images.first
      @shopify_product_image.destroy
    elsif @product_images.index(@image) == 0
      @shopify_product_image = @product.images.first
      @shopify_product_image.destroy
      @shopify_product_image = ShopifyAPI::Image.new(:product_id => @product.id)
      @shopify_product_image.src = URI.join(request.url, @product_images[1].image.url).to_s
      @shopify_product_image.save
    end

    if @image.destroy 
      redirect_to edit_product_path :id => params[:product_id] 
    end
  end
  
  private

    def image_params
      params.permit(:image_source, :title, :product_id, :image)
    end
    
end

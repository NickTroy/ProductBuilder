class VariantInfoController < ApplicationController
  before_filter :cors_preflight_check
  after_filter :cors_set_access_control_headers

  # For all responses in this controller, return the CORS access control headers.

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  # If this is a preflight OPTIONS request, then short-circuit the
  # request, return only the necessary headers and return an empty
  # text/plain.

  def cors_preflight_check
    if request.method == :options
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
      headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version'
      headers['Access-Control-Max-Age'] = '1728000'
      render :text => '', :content_type => 'text/plain'
    end
  end    
  
  def show
    @default_captions = DefaultCaption.all
    @variant = Variant.find(params[:id])
    @option_values = @variant.option_values
    @three_sixty_image = @variant.three_sixty_image
    if @three_sixty_image.nil?
      main_variant = Variant.find_by(product_id: @variant.product_id, main_variant: true).first || Variant.where(product_id: @variant.product_id).first
      @three_sixty_image = main_variant.three_sixty_image
    end
    @variant_images = []
    @variant_images = @three_sixty_image.variant_images unless @three_sixty_image.nil?
    respond_to do |format|
      format.json
    end
  end
  
  def main_variants_images
    pseudo_product_ids = params[:pseudo_product_ids]
    pseudo_product_ids_with_images_urls = {}
    pseudo_product_ids.each do |pseudo_product_id|
      main_variant_product_id = Variant.find_by(:pseudo_product_id => pseudo_product_id.split(';')[0]).product_id
      main_variant = Variant.where(:product_id => main_variant_product_id, :main_variant => true)[0] || Variant.where(:product_id => main_variant_product_id)[0]
      main_variant_image_url = ""
      if !(main_variant.three_sixty_image.nil?)
        main_variant_image_url = URI.join(request.url, main_variant.three_sixty_image.plane_images.first.azure_image.url).to_s
      elsif !(main_variant.main_image_id.nil?)
        main_variant_image_url = URI.join(request.url, VariantImage.find(main_variant.main_image_id).azure_image.url).to_s
      elsif !(main_variant.variant_images.empty?)
        main_variant_image_url = URI.join(request.url, main_variant.variant_images.first.azure_image.url).to_s
      end
      main_variant_image_url.insert(4,"s") unless main_variant_image_url[4] == "s"
      pseudo_product_ids_with_images_urls[pseudo_product_id] = main_variant_image_url
    end
    render json: pseudo_product_ids_with_images_urls, status: 200
  end
end

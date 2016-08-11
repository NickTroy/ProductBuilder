class ThreeSixtyImagesController < AuthenticatedController
  skip_before_action :verify_authenticity_token
  
  def new
    @three_sixty_image = ThreeSixtyImage.new
  end
  
  def edit
    @three_sixty_image = ThreeSixtyImage.find(params[:id])
    @plane_images = @three_sixty_image.plane_images
    @variant_images = @three_sixty_image.variant_images.sort_by &:position
    unless @three_sixty_image.nil?
      unless @three_sixty_image.plane_images.empty?      
        @first_plane_image = @three_sixty_image.plane_images.first.azure_image.url
        @three_sixty_image_url = URI.join(request.url, @first_plane_image).to_s
        @images_path = @three_sixty_image_url.split('/')
        @images_path.delete_at(-1)
        @images_path = @images_path.join('/') 
        @images_names = []
        @three_sixty_image.plane_images.each do |plane_image|
          @images_names.push(plane_image.azure_image.original_filename)
        end
        @images_names = @images_names.join(',')
      end
    end
  end

  def create
    if params[:commit] == 'Back'
      redirect_to root_url(:protocol => 'https')
      return true
    end
    @three_sixty_image = ThreeSixtyImage.new(three_sixty_image_params)
    if @three_sixty_image.save
      redirect_to edit_three_sixty_image_url(:id => @three_sixty_image.id, :protocol => 'https')
    else 
      render json: { message: "failed" }, :status => 500
    end
  end

  def update_order
    new_images_order = params[:image_order]
    new_images_order.each_index do |index|
      image = VariantImage.find new_images_order[index]
      image.position = index
      image.save
    end
    render :nothing => true
  end

  def update
    if params[:commit] == 'Back'
      redirect_to root_url(:protocol => 'https')
      return true
    end
    @three_sixty_image = ThreeSixtyImage.find(params[:id])

    unless params[:image_id].nil? 
      @image_selected = VariantImage.find(params[:image_id])
      @three_sixty_image.main_image_id = params[:image_id]
      @three_sixty_image.save
    end

    respond_to do |format|
      format.html do
        if @three_sixty_image.update_attributes(three_sixty_image_params)
          redirect_to root_url(:protocol => 'https')
        else 
          render json: { message: "failed" }, :status => 500
        end
      end
      format.json do
        unless @three_sixty_image.nil?
          unless @three_sixty_image.plane_images.empty?      
            @first_plane_image = @three_sixty_image.plane_images.first.azure_image.url
            @three_sixty_image_url = URI.join(request.url, @first_plane_image).to_s
            @images_path = @three_sixty_image_url.split('/')
            @images_path.delete_at(-1)
            @images_path = @images_path.join('/') 
            @images_names = []
            @three_sixty_image.plane_images.each do |plane_image|
              @images_names.push(plane_image.azure_image.original_filename)
            end
            @images_names = @images_names.join(',')
          end
          @three_sixty_image_info = {
            images_names: @images_names, 
            images_path: @images_path,
            first_plane_image: @first_plane_image
          }
        end
        if @three_sixty_image.update_attributes(three_sixty_image_params)
          render json: @three_sixty_image_info, :status => 200
        else 
          render json: { message: "failed" }, :status => 500
        end
      end
    end
  end
  
  def show
    @three_sixty_image = ThreeSixtyImage.find(params[:three_sixty_image_id])
    unless @three_sixty_image.plane_images.empty?
      @first_plane_image = @three_sixty_image.plane_images.first.azure_image.url
      @first_plane_image = URI.join(request.url, @first_plane_image).to_s
      @images_path = @first_plane_image.split('/')
      @images_path.delete_at(-1)
      @images_path = @images_path.join('/')
      @images_names = []
      @three_sixty_image.plane_images.each do |plane_image|
        @images_names.push(plane_image.azure_image.original_filename)
      end
    end
    @variant_images = @three_sixty_image.variant_images
  end 

  def destroy
    @three_sixty = ThreeSixtyImage.find(params[:id])
    @three_sixty.variants.each do |variant|
      @product = ShopifyAPI::Product.find(variant.product_id)
      @main_variant_image = VariantImage.find(@three_sixty.main_image_id) unless @three_sixty.main_image_id.nil?
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
    if @three_sixty.destroy
      redirect_to :back
    else
      render json: { message: "failed" }, :status => 500
    end
  end
  
  def update_all_three_sixty_images_parameters
    @three_sixty_speed = params[:three_sixty_speed]
    @three_sixty_rotations_count = params[:three_sixty_rotations_count]
    @three_sixty_clockwise = params[:three_sixty_clockwise] == "false" ? false : true
    ThreeSixtyImage.all.each do |image|
      image.update_attributes(:rotation_speed => @three_sixty_speed, :rotations_count => @three_sixty_rotations_count, :clockwise => @three_sixty_clockwise)
    end
    render json: { message: "updated" }, :status => 200
  end
  
  def upload_plane_images
    @three_sixty = ThreeSixtyImage.find(params[:three_sixty_image_id])
    @images = []
    params[:three_sixty_images].each do |number, img|
      @images.push(img)
    end
    if @three_sixty.plane_images.any?
      @three_sixty.plane_images.each do |plane_image|
        plane_image.destroy
      end
    end

    @images.each { |img| PlaneImage.create(:three_sixty_image_id => @three_sixty.id, :azure_image => img, :azure_big_image => img ) }
    @three_sixty.rotations_count = 5
    @three_sixty.rotation_speed = 5
    if @three_sixty.save
      render json: { message: "created" }, :status => 200
    else
      render json: { message: "failed" }, :status => 500
    end
  end
  
  def assign_to_variant
    @variant = Variant.find(params[:variant_id])
    @three_sixty_image = ThreeSixtyImage.find(params[:three_sixty_image_id])
    
    if @variant.update_attributes(:three_sixty_image_id => @three_sixty_image.id)
      if @three_sixty_image.plane_images.empty? 
        render json: { message: "assigned" }, status: 200
      else
        @first_plane_image = @three_sixty_image.plane_images.first.azure_image.url
        @first_plane_image = URI.join(request.url, @first_plane_image).to_s
        @images_path = @first_plane_image.split('/')
        @images_path.delete_at(-1)
        @images_path = @images_path.join('/')
        @images_names = []
        @three_sixty_image.plane_images.each do |plane_image|
          @images_names.push(plane_image.azure_image.original_filename)
        end
        @variant_images = @three_sixty_image.variant_images
        render 'show'
      end
    end
  end
  
  def delete_plane_images
    @three_sixty_image = ThreeSixtyImage.find(params[:three_sixty_image_id])
    @three_sixty_image.plane_images.each do |plane_image|
      plane_image.destroy
    end
    render json: { message: "deleted" }, :status => 200
  end

  def update_captions
    params_ids = params[:ids].split(' ')
    params_ids.map do |id|
      value = params[id.to_sym]
      VariantImage.find(id.to_i).update_attribute(:caption, value)
    end
    render nothing: true, status: 200
  end
  
  private
  
  def three_sixty_image_params
    params.require("three_sixty_image").permit(:title, :rotations_count, :rotation_speed, :clockwise, :caption_3d_image, :captions_attr => [:caption])
  end
end

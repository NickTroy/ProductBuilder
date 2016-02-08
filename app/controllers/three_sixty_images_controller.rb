class ThreeSixtyImagesController < AuthenticatedController
  skip_before_action :verify_authenticity_token

  def create
    @variant = Variant.find(params[:variant_id])
    @three_sixty = @variant.three_sixty_image || ThreeSixtyImage.create(:variant_id => params[:variant_id])
    @images = []
    params[:three_sixty_images].each do |number, img|
      @images.push(img)
    end
    if @three_sixty.plane_images.any?
      @three_sixty.plane_images.each do |plane_image|
        plane_image.destroy
      end
    end
    @images.each do |img|
      PlaneImage.create(:three_sixty_image_id => @three_sixty.id, :image => img)
    end
    @three_sixty.rotations_count = 5
    @three_sixty.rotation_speed = 5
    if @three_sixty.save
      render json: { message: "created" }, :status => 200
    else
      render json: { message: "failed" }, :status => 500
    end
  end

  def update
    @variant = Variant.find(params[:variant_id])
    @three_sixty_image = @variant.three_sixty_image
    if @three_sixty_image.update_attributes(:rotation_speed => params[:rotation_speed], :rotations_count => params[:rotations_count], :clockwise => params[:clockwise])
      render json: { message: "updated" }, :status => 200
    else 
      render json: { message: "failed" }, :status => 500
    end
  end
  
  def show
    @variant = Variant.find(params[:variant_id])
    @three_sixty_image = @variant.three_sixty_image
    unless @three_sixty_image.plane_images.empty?
      @first_plane_image = @three_sixty_image.plane_images.first.image.url
      @first_plane_image = URI.join(request.url, @first_plane_image).to_s
      @first_plane_image.insert(4,'s')
      @images_path = @first_plane_image.split('/')
      @images_path.delete_at(-1)
      @images_path = @images_path.join('/')
      @images_names = []
      @three_sixty_image.plane_images.each do |plane_image|
        @images_names.push(plane_image.image.original_filename)
      end
      #@images_names = @images_names.join(',')
    end
    
  end 

  def destroy
    @variant = Variant.find(params[:variant_id])
    @three_sixty = @variant.three_sixty_image
    if @three_sixty.destroy
      redirect_to :back
    else
      render json: { message: "failed" }, :status => 500
    end
  end
end

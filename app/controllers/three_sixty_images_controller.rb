class ThreeSixtyImagesController < AuthenticatedController
  skip_before_action :verify_authenticity_token
  
  def new
    @three_sixty_image = ThreeSixtyImage.new
  end
  
  def edit
    @three_sixty_image = ThreeSixtyImage.find(params[:id])
    @plane_images = @three_sixty_image.plane_images
    
    unless @three_sixty_image.nil?
      unless @three_sixty_image.plane_images.empty?      
        @first_plane_image = @three_sixty_image.plane_images.first.image.url
        @three_sixty_image_url = URI.join(request.url, @first_plane_image).to_s
        #@three_sixty_image_url.insert(4,'s')
        @images_path = @three_sixty_image_url.split('/')
        @images_path.delete_at(-1)
        @images_path = @images_path.join('/') 
        @images_names = []
        @three_sixty_image.plane_images.each do |plane_image|
          @images_names.push(plane_image.image.original_filename)
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

  def update
    if params[:commit] == 'Back'
      redirect_to root_url(:protocol => 'https')
      return true
    end
    @three_sixty_image = ThreeSixtyImage.find(params[:id])
    respond_to do |format|
      format.html do
        if @three_sixty_image.update_attributes(three_sixty_image_params)
          redirect_to root_url
        else 
          render json: { message: "failed" }, :status => 500
        end
      end
      format.json do
        unless @three_sixty_image.nil?
          unless @three_sixty_image.plane_images.empty?      
            @first_plane_image = @three_sixty_image.plane_images.first.image.url
            @three_sixty_image_url = URI.join(request.url, @first_plane_image).to_s
            #@three_sixty_image_url.insert(4,'s')
            @images_path = @three_sixty_image_url.split('/')
            @images_path.delete_at(-1)
            @images_path = @images_path.join('/') 
            @images_names = []
            @three_sixty_image.plane_images.each do |plane_image|
              @images_names.push(plane_image.image.original_filename)
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
      @first_plane_image = @three_sixty_image.plane_images.first.image.url
      @first_plane_image = URI.join(request.url, @first_plane_image).to_s
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
    @three_sixty = ThreeSixtyImage.find(params[:id])
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

    @images.each do |img|
      PlaneImage.create(:three_sixty_image_id => @three_sixty.id, :image => img, :big_image => img )
    end
    @three_sixty.rotations_count = 5
    @three_sixty.rotation_speed = 5
    if @three_sixty.save
      render json: { message: "created" }, :status => 200
    else
      render json: { message: "failed" }, :status => 500
    end
  end
  
  def delete_plane_images
    @three_sixty_image = ThreeSixtyImage.find(params[:three_sixty_image_id])
    @three_sixty_image.plane_images.each do |plane_image|
      plane_image.destroy
    end
    render json: { message: "deleted" }, :status => 200
  end
  
  private
  
  def three_sixty_image_params
    params.require("three_sixty_image").permit(:title, :rotations_count, :rotation_speed, :clockwise)
  end
end

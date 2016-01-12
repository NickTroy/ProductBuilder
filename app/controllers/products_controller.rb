class ProductsController < AuthenticatedController
  def index
    @products = []
    ShopifyAPI::Product.all.each do |p|
      if p.metafields[0].namespace == "product"  
        @products.push(p)    
      end  
    end
    #@products = ShopifyAPI::Product.find(:all)
    @variants = Variant.all
    @images = ProductImage.all
  end

  def new
    @product = ShopifyAPI::Product.new
  end
  
  def edit
    @product = ShopifyAPI::Product.find(params[:id])
    @images = ProductImage.where(product_id: @product.id)
    @options = Option.all
    @product_options = []
    ProductsOption.where(:product_id => @product.id).each do |product_option|
      @product_options.push(Option.where(id: product_option.option_id)[0])
    end
    #Option.joins("inner join products_options on products_options.product_id = #{params[:id]}").uniq
    @variants = Variant.where(product_id: @product.id)
  end
  
  def show
    @product = ShopifyAPI::Product.find(params[:id])
    @product_options = []
    ProductsOption.where(:product_id => @product.id).each do |product_option|
      @product_options.push(Option.where(id: product_option.option_id)[0])
    end
    #@product_options = Option.joins("inner join products_options on products_options.product_id = #{params[:id]}").uniq
    @variants = Variant.where(product_id: @product.id)
    #respond_to do |format|
     # format.json { render 'show.json.jbuilder' }
    #end
  end
  
  def create
    
    if params[:commit] == 'Back to all products'
      redirect_to root_path
      return true
    end
    
    @product = ShopifyAPI::Product.new(product_params)   
    respond_to do |format|
      format.html do 
        if @product.save
          @product.add_metafield(ShopifyAPI::Metafield.new(:namespace => "product", :key => "key", :value => "value", :value_type => "string"))
          redirect_to edit_product_url(:id => @product.id, :protocol => 'https')
        end
      end
    end
  end
  
  def update
    
    if params[:commit] == 'Back to all products'
      redirect_to root_url(:protocol => 'https')
      return true
    end
    
    @product = ShopifyAPI::Product.find(params[:id])
    
    respond_to do |format|
      format.html do 
        if @product.update_attributes(product_params)
          redirect_to products_url(:protocol => 'https')
        end
      end
    end
  end

  
  
  def destroy
    @product = ShopifyAPI::Product.find(params[:id])
    @images = ProductImage.where(product_id: params[:id])
    @variants = Variant.where(product_id: params[:id])
    
    @product_options = Option.where(product_id: params[:id])
    @images.each { |img| img.destroy }
    @variants.each do |var|  
      @pseudo_product = ShopifyAPI::Product.find(var.pseudo_product_id)
      @pseudo_product.destroy
      var.destroy
    end
    @options.each { |opt| opt.destroy } unless @options.nil?
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url(:protocol => 'https'), notice: 'Product was successfully deleted.' }
    end
    
  end

  private

    def product_params
      params.permit(:body_html, :handle, :options, 
                    :product_type, :published_scope, :tags,
                    :template_suffix, :title, :variants, :vendor)
    end
    
end

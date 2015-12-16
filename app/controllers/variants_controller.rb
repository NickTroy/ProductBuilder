class VariantsController < ApplicationController

  def index
    @variants = Variant.all
    respond_to do |format|
      format.json { render 'index' }
    end
  end
  
  def generate_product_variants
    respond_to do |format|
      format.json do
        params[:variants].each do |variant|
          @variant = Variant.new(product_id: params[:product_id])
          variant[1].each do |option_value| 
            @option_value = OptionValue.find_by(value: option_value)
            @variant.option_values << @option_value
          end
          @variant.save
        end
        
        redirect_to :back#edit_product_path(params[:product_id])
        
      end
    end
  end
  



end

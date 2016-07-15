module ProductsHelper
  DATA_ROW = 6
  TITLE_ROW = 0
  DESCR_ROW = 1
  OPTIONS_COL_FROM = 20
  FORBIDDEN_FIELDS = ["created_at", "updated_at", "variants", "images", "image",  "handle", "published_at", 
                          "template_suffix", "published_scope", "tags", "options","id", "handle", "main_product_id", 
                          "created_at", "updated_at", "product_id", "product_image_id", "pseudo_product_id", 
                          "pseudo_product_variant_id", "product_details", "main_variant", "three_sixty_image_id", "shipping_method_id" ]
  
  def parse_import_file import_file_path
    import_file = Roo::Excel.new( import_file_path )
    import_file.each_with_pagename do |name, sheet|
      _data = get_variable sheet, 'data'
      _info = get_variable sheet, 'info'
      _variants = get_variants sheet   

      persist_product _data, _info, _variants
    end
    import_file.close
  end

  def create_export_file
    book = Spreadsheet::Workbook.new
    product_ids = params[:product_ids].split(',').map!(&:to_i)
    product_ids.each_with_index do |product_id, index|
      product = ShopifyAPI::Product.find(product_id)
      _sheet = book.create_worksheet(:name => "product ##{index + 1}")
      _data     = get_product_data product
      _info     = get_product_info product
      _variants = get_product_variants product
      
      write_product _sheet, _data, _info, _variants
    end
    book.write './public/assets/export.xls'
  end
  
  private 
  
  def write_product sheet, data, info, variants
    col_pointer = 0
    title_row = sheet.row TITLE_ROW
    data_row = sheet.row DATA_ROW
    desc_row = sheet.row DESCR_ROW
    
    data.keys.each do |key|
      title_row[col_pointer] = 'data'
      desc_row[col_pointer] = key
      data_row[col_pointer] = data[key]
      col_pointer += 1
    end
    
    info.keys.each do |key|
      title_row[col_pointer] = 'info'
      desc_row[col_pointer] = key
      data_row[col_pointer] = info[key]
      col_pointer += 1
    end
    
    variant_offset = col_pointer
    variant_data_row = sheet.row DATA_ROW
    
    
    variants.each_with_index do |variant, i|
      
      col_pointer = variant_offset
      title_row[col_pointer] = 'variant'
      desc_row[col_pointer] = 'n'
      variant_data_row[col_pointer] = i
      col_pointer += 1
      
      variant.keys.each do |key|
        if variant[key].class != Array
          title_row[col_pointer] = 'variant'
          desc_row[col_pointer] = key
          variant_data_row[col_pointer] = variant[key]
          col_pointer += 1
        end
      end
      
      variant['options'].each do |op|
        title_row[col_pointer] = 'variant opt'
        desc_row[col_pointer] = op.keys.first
        variant_data_row[col_pointer] = op.values.first
        col_pointer += 1
      end
      
      unless variant['three_sixty_image'].nil?
        variant['variant_images'].each do |img|
          title_row[col_pointer] = 'variant v_imgs'
          variant_data_row[col_pointer] =  URI.join(request.url, img.azure_image.url).to_s
          col_pointer += 1
        end 
        variant['plane_images'].each do |img|
          title_row[col_pointer] = 'variant p_imgs'
          variant_data_row[col_pointer] =  URI.join(request.url, img.azure_image.url).to_s
          col_pointer += 1
        end
      end
      variant_data_row = sheet.row(DATA_ROW + 1 + i)
    end
  end
  
  def persist_product data, info, variants
    _product = ShopifyAPI::SmartCollection.where(title:"Product_builder_products").first.products.find { |product| product.title == data['title'] }
    
    if _product.nil?
      _product = ShopifyAPI::Product.new data
      _product.attributes[:tags] = "product" unless _product.attributes[:tags] == "product"
      _product.save
    end 
    
     _product_info = ProductInfo.find_by(main_product_id: _product.id) || ProductInfo.create(:main_product_id => _product.id, :handle => _product.handle)
    unless info['shipping_method_name'].nil?
      shipping_method = ShippingMethod.find_by(name: info['shipping_method_name'] ) || ShippingMethod.create(name: info['shipping_method_name'] )
      shipping_method.product_infos << _product_info
    end

    _product_info.update_attributes({
      "be_sure_to_note" => info["be_sure_to_note"],
      "why_we_love_this" => info["why_we_love_this"],
      "country_of_origin" => info["country_of_origin"],
      "primary_materials" => info["primary_materials"],
      "requires_assembly" => info["requires_assembly"],
      "care_instructions" => info["care_instructions"],
      "shipping_restrictions" => info["shipping_restrictions"],
      "return_policy"=> info["return_policy"],
      "lead_time"=> info["lead_time"],
      "lead_time_unit"=> info["lead_time_unit"],
      "shipping_method_id"=> shipping_method.id
    })
    
    0.upto( variants.length - 1 ) do |i|

      variant = Variant.find_by(:product_id => _product.id, :sku => variants[i]['sku'])
      if variant.blank? or variants[i]['sku'].blank?
        variant = Variant.create(:product_id => _product.id) 
      else
        pseudo_product_title = "#{_product.title} "
        o = variant.option_values.joins("join options on options.id = option_values.option_id").select("options.name as option_name, option_values.value as value")
        color_option_value = o.find { |option| option.option_name == "Color" }
        pseudo_product_title += color_option_value.nil? ? "(" : "(#{color_option_value.value} " 
        upholstery_option_value = o.find { |option| option.option_name == "Upholstery"}
        pseudo_product_title += upholstery_option_value.nil? ? ")" : "#{upholstery_option_value.value})"
        length_option_value = o.find { |option| option.option_name == "Lengths" }
        length_option_value = length_option_value.value unless length_option_value.nil?
        depth_option_value = o.find { |option| option.option_name == "Depth" }
        depth_option_value = depth_option_value.value unless depth_option_value.nil?
        pseudo_product_title = "#{length_option_value} #{depth_option_value} #{pseudo_product_title}"
        pseudo_product = ShopifyAPI::Product.create(title: "#{pseudo_product_title}") 
        pseudo_product_variant = pseudo_product.variants.first
        pseudo_product_variant.update_attributes(:option1 => pseudo_product_title, :price => variant.price, :sku => variant.sku)
        variant.update_attributes(:pseudo_product_id => pseudo_product.id, :pseudo_product_variant_id => pseudo_product_variant.id)
      end

      variants[i]['options'].keys.each do |key|
        option = Option.where(name: key).first || Option.create(name: key)
        if option.products_options.where(:product_id => _product.id).empty?
          option.products_options.create(:product_id => _product.id)
        end
        unless variants[i]['options'][key].nil? 
          curr_option_value = variant.option_values.where( option_id: option.id ).first
          new_option_value = OptionValue.where( :value => variants[i]['options'][key].capitalize ).first
          new_option_value = OptionValue.create :option_id => option.id, :value => variants[i]['options'][key].capitalize if new_option_value.nil?
          
          if curr_option_value.present? 
            if curr_option_value.value != variants[i]['options'][key]
              variant.option_values.delete curr_option_value
              variant.option_values << new_option_value
            end
          else
            variant.option_values << new_option_value
          end
        end
      end
      
      variant_keys = variant.attributes.keys.collect! { |x| x unless FORBIDDEN_FIELDS.include? x }.compact!
      variant_hash = {}
      variant_keys.each do |key|
        variant_hash[key.to_sym] = variants[i][key]
      end
      variant.update_attributes variant_hash
      
      unless variants[i]['three_sixty_image'].blank?
        imgSet = ThreeSixtyImage.where( :title => variants[i]['three_sixty_image'] ).first
        if imgSet.nil?
          imgSet = ThreeSixtyImage.create(:title => variants[i]['three_sixty_image'],
                                          :rotation_speed => variants[i]['three_sixty_image_rs'], 
                                          :rotations_count => variants[i]['three_sixty_image_rc'] , 
                                          :clockwise => variants[i]['three_sixty_image_c'] )
          variants[i]['variant_images'].each do |img|
            unless img.blank?
              variant_image = VariantImage.new(:three_sixty_image_id => imgSet.id)
              variant_image.azure_image_from_url img
              variant_image.save
            end  
          end
          variants[i]['plane_images'].each do |img|
            unless img.blank?
              plane_image = PlaneImage.new(:three_sixty_image_id => imgSet.id)
              plane_image.azure_image_from_url img
              plane_image.save
            end
          end
        end
        variant.three_sixty_image = imgSet
      end
      variant.save
      
    end     
  end
  
  def get_variable sheet, variable
    _h = Hash.new
    title_row = sheet.row TITLE_ROW + 1
    title_row.each_with_index do |title, i|
      if title.upcase.include? variable.upcase
        _col = sheet.column i + 1
        _h["#{_col[DESCR_ROW]}"] = _col.slice( DATA_ROW, _col.length).compact.uniq.join
      end
    end
    _h  
  end
  
  def get_variants sheet
    title_row = sheet.row TITLE_ROW + 1
    desc_row = sheet.row DESCR_ROW + 1
    data_row_offset = 0
    variant_n_col = sheet.column title_row.index('variant') + 1
    variant_num = variant_n_col.slice( DATA_ROW, variant_n_col.length).compact.length
    variants = []
    1.upto(variant_num) do 
      _h = Hash.new
      _h['options'] = {}
      _h['variant_images'] = []
      _h['plane_images'] = []
      title_row.each_with_index do |title, index|
        data_row = sheet.row DATA_ROW + 1 + data_row_offset
        if title.upcase.include? 'VARIANT'
          if title.upcase === 'VARIANT'
            _h[ "#{desc_row[index]}"] = data_row[index]
          end
          if title.upcase.include? 'OPT'
            _h['options']["#{desc_row[index]}"] = data_row[index] 
          end
          if title.upcase.include? 'V_IMGS'
            _h['variant_images'] << data_row[index]
          end
          if title.upcase.include? 'P_IMGS'
            _h['plane_images'] << data_row[index]
          end
        end
      end
      variants.push _h
      data_row_offset += 1
    end
    variants
  end
  
  
  def get_product_data product
    product_keys = product.attributes.keys 
    product_keys.collect! { |x| x unless FORBIDDEN_FIELDS.include? x }.compact!
    Hash[product_keys.collect { |v| [v, eval("product.#{v}")] }]
  end
  
  def get_product_info product
    product_info = ProductInfo.find_by(main_product_id: product.id)
    product_info_keys = product_info.attributes.keys
    product_info_keys.collect! { |x| x unless FORBIDDEN_FIELDS.include? x }.compact!
    Hash[product_info_keys.collect { |v| [v, eval("product_info.#{v}")] } ]
  end
  
  def get_product_variants product
    product_variants = Variant.where(:product_id => product.id)
    options = Option.all
    _variants_a = product_variants.collect do |p|
      variant_keys = p.attributes.keys.collect! { |x| x unless FORBIDDEN_FIELDS.include? x }.compact!
      _h = Hash[variant_keys.collect { |v| [v, eval("p.#{v}")] } ]
      
      _h['shipping_method_name'] = p.shipping_method.name
      
      _h['options'] = options.collect do |option|
        value = p.option_values.find_by(option_id: option.id) 
        Hash[ option.name, value.nil? ? nil : value.value ]
      end
      
      unless p.three_sixty_image.nil?
        _h['three_sixty_image'] = ThreeSixtyImage.find(p.three_sixty_image_id).title
        tsi = ThreeSixtyImage.find(p.three_sixty_image_id)
        _h['three_sixty_image'] = tsi.title
        _h['three_sixty_image_rs'] = tsi.rotation_speed
        _h['three_sixty_image_rc'] = tsi.rotations_count
        _h['three_sixty_image_c'] = tsi.clockwise
        _h['variant_images'] = p.three_sixty_image.variant_images.to_a
        _h['plane_images'] = p.three_sixty_image.plane_images.to_a
      else
        _h['three_sixty_image'] = nil
        _h['three_sixty_image_rs'] = nil
        _h['three_sixty_image_rc'] = nil
        _h['three_sixty_image_c'] = nil
      end
      _h
    end
    _variants_a
  end

end

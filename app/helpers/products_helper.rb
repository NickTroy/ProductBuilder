module ProductsHelper
  DATA_ROW = 6
  TITLE_ROW = 0
  DESCR_ROW = 1
  OPTIONS_COL_FROM = 20
  FORBIDDEN_FIELDS = ["created_at", "updated_at", "variants", "images", "image",  "handle", "published_at", 
                          "template_suffix", "published_scope", "tags", "options","id", "handle", "main_product_id", 
                          "created_at", "updated_at", "product_id", "product_image_id", "pseudo_product_id", 
                          "pseudo_product_variant_id", "product_details", "main_variant", "three_sixty_image_id" ]
  
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
          variant_data_row[col_pointer] =  URI.join(request.url, img.image.url).to_s
          col_pointer += 1
        end 
        
        variant['plane_images'].each do |img|
          title_row[col_pointer] = 'variant p_imgs'
          variant_data_row[col_pointer] =  URI.join(request.url, img.image.url).to_s
          col_pointer += 1
        end
      end
      variant_data_row = sheet.row(DATA_ROW + i)
    end
  end
  
  def persist_product data, info, variants
    _product = ShopifyAPI::SmartCollection.where(title:"Product_builder_products").first.products.find { |product| product.title == data['title'] }
    if _product.nil?
      _product = ShopifyAPI::Product.new({
        :title => data['title'],
        :body_html => data['body_html'],
        :vendor => data['vendor'],
        :product_type => data['type']
      })
      _product.attributes[:tags] = "product" unless _product.attributes[:tags] == "product"
      _product.save
    end 
    
     _product_info = ProductInfo.find_by(main_product_id: _product.id) || ProductInfo.create(:main_product_id => _product.id, :handle => _product.handle)
    unless info['shipping_method_name'].nil?
      shipping_method = ShippingMethod.find_by(name: info['shipping_method_name'] ) || ShippingMethod.create(name: info['shipping_method_name'] )
      shipping_method.product_infos << _product_info
    end
    _product_info.update_attributes({
      :why_we_love_this => info['why_we_love_this'],
      :be_sure_to_note => info['be_sure_to_note'],
      :country_of_origin => info['country_of_origin'],
      :primary_materials => info['primary_materials'],
      :requires_assembly => info['requires_assembly'],
      :lead_time => info['lead_time'],
      :lead_time_unit => info['lead_time_unit'],
      :care_instructions => info['care_instructions'],
      :shipping_restrictions => info['shipping_restrictions'],
      :return_policy => info['return_policy']
    })
    
    0.upto( variants.length - 1 ) do |i|
      variant_updating = true
      variant = Variant.find_by(:product_id => _product.id, :sku => variants[i]['sku'])
      if variant.nil? or variants[i]['sku'] == "" or variants[i]['sku'].nil? or variant.sku.nil?
        variant_updating = false
        variant = Variant.create(:product_id => _product.id) 
        variants[i]['options'].keys.each do |key|
          option = Option.where(name: key).first || Option.create(name: key)
          if option.products_options.where(:product_id => _product.id).empty?
            option.products_options.create(:product_id => _product.id)
          end
          option_value = option.option_values.where(:value => variants[i]['options'][key].capitalize)[0] || OptionValue.create(:option_id => option.id, :value => variants[i]['options'][key].capitalize)
          variant.option_values << option_value
        end
      end  
      
      variant_keys = variant.attributes.keys.collect! { |x| x unless FORBIDDEN_FIELDS.include? x }.compact!
      variant_hash = {}
      variant_keys.each do |key|
        variant_hash[key.to_sym] = variants[i][key]
      end
      variant.update_attributes variant_hash
      
      pseudo_product_title = "#{_product.title} "
      o = variant.option_values.joins("join options on options.id = option_values.option_id").select("options.name as option_name, option_values.value as value")
      color_option_value = o.find { |option| option.option_name == "Color" }
      pseudo_product_title += color_option_value.nil? ? "(" : "(#{color_option_value.value} " 
      upholstery_option_value = o.find { |option| option.option_name == "Upholstery"}
      pseudo_product_title += upholstery_option_value.nil? ? ")" : "#{upholstery_option_value.value})"
      variant_length = o.find { |option| option.option_name == "Lengths" }
      variant_length = variant_length.value unless variant_length.nil?
      variant_depth = o.find { |option| option.option_name == "Depth" }
      variant_depth = variant_depth.value unless variant_depth.nil?
      pseudo_product_title = "#{variant_length} #{variant_depth} #{pseudo_product_title}"
      
      unless variants[i]['three_sixty_image'].nil? or variants[i]['three_sixty_image'] == ''
        imgSet = ThreeSixtyImage.where( :title => variants[i]['three_sixty_image'] ).first
        unless imgSet.nil?
          variant.three_sixty_image = imgSet
        else
          imgSet = ThreeSixtyImage.create(:title => variants[i]['three_sixty_image'])
          variants[i]['variant_images'].each do |img|
            variant_image = VariantImage.new(:three_sixty_image_id => imgSet.id)
            variant_image.image_from_url(img)
            variant_image.save
          end
          variants[i]['plane_images'].each do |img|
            plane_image = PlaneImage.new(:three_sixty_image_id => imgSet.id)
            plane_image.image_from_url(img)
            plane_image.save
          end
          
        end
      end
      variant.save
      sleep 0.5
      unless variant_updating
        pseudo_product = ShopifyAPI::Product.create(title: "#{pseudo_product_title}") 
        pseudo_product_variant = pseudo_product.variants.first
        pseudo_product_variant.update_attributes(:option1 => pseudo_product_title, :price => variant.price, :sku => variant.sku)
        variant.update_attributes(:pseudo_product_id => pseudo_product.id, :pseudo_product_variant_id => pseudo_product_variant.id)
      end
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
    _variants_a = product_variants.collect do |p|
      variant_keys = p.attributes.keys.collect! { |x| x unless FORBIDDEN_FIELDS.include? x }.compact!
      _h = Hash[variant_keys.collect { |v| [v, eval("p.#{v}")] } ]
      _h['options'] = p.option_values.collect { |v| Hash[ Option.where("id = #{v.option_id}").first.name, v.value ]}
      unless p.three_sixty_image.nil?
        _h['three_sixty_image'] = ThreeSixtyImage.find(p.three_sixty_image_id).title
        _h['variant_images'] = p.three_sixty_image.variant_images.to_a
        _h['plane_images'] = p.three_sixty_image.plane_images.to_a
      end
      _h
    end
    _variants_a
  end

end

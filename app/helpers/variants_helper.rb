module VariantsHelper
  class Auth < AuthenticatedController
    def self.shopify
      domain = "tandemarbor.myshopify.com"
      token = "dce1a15bcaf1e9e4c5a0b1f48097e0da"
      session = ShopifyAPI::Session.new(domain, token)
      ShopifyAPI::Base.activate_session(session)
   end
 end

  def repairPseudoVariants
    # 5418551557 - Hudson Sofa
    variants = Variant.where product_id: 5418551557
    variants.each do |variant|
      Auth.shopify
      pseudo_variant =  ShopifyAPI::Variant.find variant.pseudo_product_variant_id
      sleep 0.5
      puts "Variant: #{variant.price} - Pseudo: #{pseudo_variant.price}"
      pseudo_variant.update_attributes({ price: variant.price, sku: variant.sku })
      sleep 0.5
    end
  end
end

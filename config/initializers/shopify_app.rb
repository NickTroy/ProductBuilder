ShopifyApp.configure do |config|
  config.api_key = "e183d50516e620411040157674e8b304"
  config.secret = "e9d6d614db13892494ae4b22c849fa36"
  config.redirect_uri = "productbuilder.herokuapp.com/auth/shopify/callback"
  config.scope = "read_orders, read_products"
  config.embedded_app = true
end

Paperclip::Attachment.default_options[:storage] = :azure_storage
Paperclip::Attachment.default_options[:url] = ':azure_path_url'
Paperclip::Attachment.default_options[:path] = ":class/:attachment/:id/:style/:filename"
Paperclip::Attachment.default_options[:azure_credentials] = {
    account_name: Rails.application.secrets.account_name,
    access_key:   Rails.application.secrets.access_key,
    azure_container: Rails.application.secrets.azure_container
}
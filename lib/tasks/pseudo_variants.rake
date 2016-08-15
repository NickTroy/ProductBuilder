namespace :ps_variant do
  desc "Repair Pseudo variants price and sku"
  task repair: :environment do
    include VariantsHelper
    repairPseudoVariants
  end
end

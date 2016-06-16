# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160616095225) do

  create_table "color_ranges", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "color",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "images_variants", force: :cascade do |t|
    t.integer  "image_id",   limit: 4
    t.integer  "variant_id", limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "images_variants", ["image_id"], name: "index_images_variants_on_image_id", using: :btree
  add_index "images_variants", ["variant_id"], name: "index_images_variants_on_variant_id", using: :btree

  create_table "option_groups", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "option_values", force: :cascade do |t|
    t.integer  "option_id",          limit: 4
    t.string   "value",              limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size",    limit: 4
    t.datetime "image_updated_at"
    t.integer  "height",             limit: 4
    t.integer  "width",              limit: 4
  end

  add_index "option_values", ["option_id"], name: "index_option_values_on_option_id", using: :btree
  add_index "option_values", ["value"], name: "index_option_values_on_value", using: :btree

  create_table "options", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "order_number",    limit: 4
    t.integer  "option_group_id", limit: 4
  end

  add_index "options", ["name"], name: "index_options_on_name", using: :btree
  add_index "options", ["option_group_id"], name: "index_options_on_option_group_id", using: :btree

  create_table "plane_images", force: :cascade do |t|
    t.integer  "three_sixty_image_id",   limit: 4
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "image_file_name",        limit: 255
    t.string   "image_content_type",     limit: 255
    t.integer  "image_file_size",        limit: 4
    t.datetime "image_updated_at"
    t.string   "big_image_file_name",    limit: 255
    t.string   "big_image_content_type", limit: 255
    t.integer  "big_image_file_size",    limit: 4
    t.datetime "big_image_updated_at"
  end

  add_index "plane_images", ["three_sixty_image_id"], name: "index_plane_images_on_three_sixty_image_id", using: :btree

  create_table "product_images", force: :cascade do |t|
    t.integer  "product_id",         limit: 8
    t.text     "image_source",       limit: 16777215
    t.string   "title",              limit: 255
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size",    limit: 4
    t.datetime "image_updated_at"
  end

  create_table "product_infos", force: :cascade do |t|
    t.string   "handle",                limit: 255
    t.integer  "main_product_id",       limit: 8
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.text     "be_sure_to_note",       limit: 65535
    t.text     "why_we_love_this",      limit: 65535
    t.string   "country_of_origin",     limit: 255
    t.string   "primary_materials",     limit: 255
    t.boolean  "requires_assembly"
    t.text     "care_instructions",     limit: 65535
    t.text     "shipping_restrictions", limit: 65535
    t.text     "return_policy",         limit: 65535
    t.string   "lead_time",             limit: 255
    t.string   "lead_time_unit",        limit: 255
    t.integer  "shipping_method_id",    limit: 4
  end

  add_index "product_infos", ["shipping_method_id"], name: "index_product_infos_on_shipping_method_id", using: :btree

  create_table "products_options", force: :cascade do |t|
    t.integer  "product_id", limit: 8
    t.integer  "option_id",  limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "products_options", ["option_id"], name: "index_products_options_on_option_id", using: :btree
  add_index "products_options", ["product_id"], name: "index_products_options_on_product_id", using: :btree

  create_table "shipping_methods", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.text     "description",    limit: 65535
    t.string   "lead_time",      limit: 255
    t.string   "lead_time_unit", limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "shops", force: :cascade do |t|
    t.string   "shopify_domain", limit: 255, null: false
    t.string   "shopify_token",  limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shops", ["shopify_domain"], name: "index_shops_on_shopify_domain", unique: true, using: :btree

  create_table "slider_images_params", force: :cascade do |t|
    t.string   "product_type",    limit: 255
    t.text     "base_size_ratio", limit: 65535
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "three_sixty_images", force: :cascade do |t|
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "rotation_speed",  limit: 255
    t.string   "rotations_count", limit: 255
    t.boolean  "clockwise"
    t.string   "title",           limit: 255
    t.integer  "main_image_id",   limit: 4
  end

  create_table "variant_images", force: :cascade do |t|
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "image_file_name",      limit: 255
    t.string   "image_content_type",   limit: 255
    t.integer  "image_file_size",      limit: 4
    t.datetime "image_updated_at"
    t.integer  "three_sixty_image_id", limit: 4
  end

  add_index "variant_images", ["three_sixty_image_id"], name: "index_variant_images_on_three_sixty_image_id", using: :btree

  create_table "variants", force: :cascade do |t|
    t.integer  "product_id",                limit: 8
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.decimal  "price",                                   precision: 10
    t.string   "sku",                       limit: 255
    t.integer  "product_image_id",          limit: 4
    t.integer  "pseudo_product_id",         limit: 8
    t.integer  "pseudo_product_variant_id", limit: 8
    t.text     "product_details",           limit: 65535
    t.string   "length",                    limit: 255
    t.string   "height",                    limit: 255
    t.string   "depth",                     limit: 255
    t.boolean  "main_variant"
    t.integer  "three_sixty_image_id",      limit: 4
    t.string   "vendor_sku",                limit: 255
    t.string   "room",                      limit: 255
    t.text     "care_instructions",         limit: 65535
    t.integer  "weight",                    limit: 4
    t.string   "condition",                 limit: 255
  end

  add_index "variants", ["product_image_id"], name: "index_variants_on_product_image_id", using: :btree
  add_index "variants", ["three_sixty_image_id"], name: "index_variants_on_three_sixty_image_id", using: :btree

  create_table "variants_option_values", force: :cascade do |t|
    t.integer  "variant_id",      limit: 4
    t.integer  "option_value_id", limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "variants_option_values", ["option_value_id"], name: "index_variants_option_values_on_option_value_id", using: :btree
  add_index "variants_option_values", ["variant_id"], name: "index_variants_option_values_on_variant_id", using: :btree

  add_foreign_key "images_variants", "product_images", column: "image_id"
  add_foreign_key "images_variants", "variants"
  add_foreign_key "option_values", "options"
  add_foreign_key "options", "option_groups"
  add_foreign_key "plane_images", "three_sixty_images"
  add_foreign_key "product_infos", "shipping_methods"
  add_foreign_key "products_options", "options"
  add_foreign_key "variant_images", "three_sixty_images"
  add_foreign_key "variants", "product_images"
  add_foreign_key "variants", "three_sixty_images"
  add_foreign_key "variants_option_values", "option_values"
  add_foreign_key "variants_option_values", "variants"
end

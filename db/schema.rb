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

ActiveRecord::Schema.define(version: 20151218125733) do

  create_table "option_values", force: :cascade do |t|
    t.integer  "option_id",  limit: 4
    t.string   "value",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "option_values", ["option_id"], name: "index_option_values_on_option_id", using: :btree

  create_table "options", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "product_id", limit: 8
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "product_images", force: :cascade do |t|
    t.integer  "product_id",   limit: 8
    t.text     "image_source", limit: 16777215
    t.string   "title",        limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "shops", force: :cascade do |t|
    t.string   "shopify_domain", limit: 255, null: false
    t.string   "shopify_token",  limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shops", ["shopify_domain"], name: "index_shops_on_shopify_domain", unique: true, using: :btree

  create_table "variants", force: :cascade do |t|
    t.integer  "product_id",       limit: 8
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.decimal  "price",                        precision: 10
    t.string   "sku",              limit: 255
    t.integer  "image_id",         limit: 4
    t.integer  "product_image_id", limit: 4
  end

  add_index "variants", ["image_id"], name: "index_variants_on_image_id", using: :btree
  add_index "variants", ["product_image_id"], name: "index_variants_on_product_image_id", using: :btree

  create_table "variants_option_values", force: :cascade do |t|
    t.integer  "variant_id",      limit: 4
    t.integer  "option_value_id", limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "variants_option_values", ["option_value_id"], name: "index_variants_option_values_on_option_value_id", using: :btree
  add_index "variants_option_values", ["variant_id"], name: "index_variants_option_values_on_variant_id", using: :btree

  add_foreign_key "option_values", "options"
  add_foreign_key "variants", "product_images"
  add_foreign_key "variants_option_values", "option_values"
  add_foreign_key "variants_option_values", "variants"
end

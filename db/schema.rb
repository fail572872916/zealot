# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_10_19_110202) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_analytics_views_per_days", force: :cascade do |t|
    t.string "site", null: false
    t.string "page", null: false
    t.date "date", null: false
    t.bigint "total", default: 1, null: false
    t.string "referrer_host"
    t.string "referrer_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_active_analytics_views_per_days_on_date"
    t.index ["referrer_host", "referrer_path", "date"], name: "index_active_analytics_views_per_days_on_referrer_and_date"
    t.index ["site", "page", "date"], name: "index_active_analytics_views_per_days_on_site_and_date"
  end

  create_table "apps", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_apps_on_name"
  end

  create_table "apps_users", id: false, force: :cascade do |t|
    t.bigint "app_id", null: false
    t.bigint "user_id", null: false
    t.index ["app_id", "user_id"], name: "index_apps_users_on_app_id_and_user_id"
    t.index ["user_id", "app_id"], name: "index_apps_users_on_user_id_and_app_id"
  end

  create_table "channels", force: :cascade do |t|
    t.bigint "scheme_id"
    t.string "name", null: false
    t.string "slug", null: false
    t.string "bundle_id", default: "*"
    t.string "device_type", null: false
    t.string "git_url"
    t.string "password"
    t.string "key"
    t.index ["bundle_id"], name: "index_channels_on_bundle_id"
    t.index ["device_type"], name: "index_channels_on_device_type"
    t.index ["name"], name: "index_channels_on_name"
    t.index ["scheme_id", "device_type"], name: "index_channels_on_scheme_id_and_device_type"
    t.index ["slug"], name: "index_channels_on_slug", unique: true
  end

  create_table "channels_web_hooks", id: false, force: :cascade do |t|
    t.bigint "channel_id", null: false
    t.bigint "web_hook_id", null: false
    t.datetime "created_at"
    t.index ["channel_id", "web_hook_id"], name: "index_channels_web_hooks_on_channel_id_and_web_hook_id"
    t.index ["web_hook_id", "channel_id"], name: "index_channels_web_hooks_on_web_hook_id_and_channel_id"
  end

  create_table "debug_file_metadata", force: :cascade do |t|
    t.bigint "debug_file_id", null: false
    t.string "uuid"
    t.string "type"
    t.string "object"
    t.jsonb "data", default: {}, null: false
    t.integer "size"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["debug_file_id"], name: "index_debug_file_metadata_on_debug_file_id"
  end

  create_table "debug_files", force: :cascade do |t|
    t.bigint "app_id"
    t.string "device_type"
    t.string "release_version"
    t.string "build_version"
    t.string "file"
    t.string "checksum"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["app_id"], name: "index_debug_files_on_app_id"
  end

  create_table "devices", force: :cascade do |t|
    t.string "udid", null: false
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "model"
    t.index ["udid"], name: "index_devices_on_udid"
  end

  create_table "devices_releases", id: false, force: :cascade do |t|
    t.bigint "release_id", null: false
    t.bigint "device_id", null: false
    t.index ["device_id", "release_id"], name: "index_devices_releases_on_device_id_and_release_id"
    t.index ["release_id", "device_id"], name: "index_devices_releases_on_release_id_and_device_id"
  end

  create_table "metadata", force: :cascade do |t|
    t.bigint "release_id"
    t.bigint "user_id"
    t.string "device", null: false
    t.string "name"
    t.string "release_version"
    t.string "build_version"
    t.string "bundle_id"
    t.integer "size"
    t.string "min_sdk_version"
    t.string "target_sdk_version"
    t.jsonb "activities", default: [], null: false
    t.jsonb "services", default: [], null: false
    t.jsonb "permissions", default: [], null: false
    t.jsonb "features", default: [], null: false
    t.string "release_type"
    t.jsonb "mobileprovision", default: {}, null: false
    t.jsonb "developer_certs", default: [], null: false
    t.jsonb "entitlements", default: {}, null: false
    t.jsonb "devices", default: [], null: false
    t.jsonb "capabilities", default: [], null: false
    t.jsonb "url_schemes", default: [], null: false
    t.string "checksum", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "releases", force: :cascade do |t|
    t.bigint "channel_id"
    t.string "bundle_id", null: false
    t.integer "version", null: false
    t.string "release_version", null: false
    t.string "build_version", null: false
    t.string "release_type"
    t.string "source"
    t.string "branch"
    t.string "git_commit"
    t.string "icon"
    t.string "ci_url"
    t.jsonb "changelog", null: false
    t.string "file"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "custom_fields", default: [], null: false
    t.string "name"
    t.string "device_type"
    t.index ["build_version"], name: "index_releases_on_build_version"
    t.index ["bundle_id"], name: "index_releases_on_bundle_id"
    t.index ["channel_id", "version"], name: "index_releases_on_channel_id_and_version", unique: true
    t.index ["release_type"], name: "index_releases_on_release_type"
    t.index ["release_version", "build_version"], name: "index_releases_on_release_version_and_build_version"
    t.index ["source"], name: "index_releases_on_source"
    t.index ["version"], name: "index_releases_on_version"
  end

  create_table "schemes", force: :cascade do |t|
    t.bigint "app_id"
    t.string "name", null: false
    t.index ["app_id"], name: "index_schemes_on_app_id"
    t.index ["name"], name: "index_schemes_on_name"
  end

  create_table "settings", force: :cascade do |t|
    t.string "var", null: false
    t.text "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["var"], name: "index_settings_on_var", unique: true
  end

  create_table "user_providers", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name"
    t.string "uid"
    t.string "token"
    t.integer "expires_at"
    t.boolean "expires"
    t.string "refresh_token"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name", "uid"], name: "index_user_providers_on_name_and_uid"
    t.index ["user_id"], name: "index_user_providers_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "token", default: "", null: false
    t.integer "role", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "web_hooks", force: :cascade do |t|
    t.bigint "channel_id"
    t.string "url"
    t.text "body"
    t.integer "upload_events", limit: 2
    t.integer "download_events", limit: 2
    t.integer "changelog_events", limit: 2
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["channel_id"], name: "index_web_hooks_on_channel_id"
    t.index ["url"], name: "index_web_hooks_on_url"
  end

end

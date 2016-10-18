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

ActiveRecord::Schema.define(version: 20140306003222) do

  create_table "account_requests", force: true do |t|
    t.string   "username",   limit: 20
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "approved",              default: false
    t.string   "domain",     limit: 20
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "done",                  default: false
  end

  create_table "announcements", force: true do |t|
    t.text     "summary"
    t.text     "body"
    t.integer  "da",         limit: 1
    t.datetime "start"
    t.datetime "end"
    t.datetime "created_at"
    t.string   "billing",    limit: 127
    t.integer  "section_id",             default: 1
    t.integer  "user_id"
  end

  add_index "announcements", ["start"], name: "item_start_index", using: :btree

  create_table "buildings", force: true do |t|
#    t.string   "name"
#    t.integer  "neighborhood_id"
#    t.integer  "built"
#    t.integer  "number_bathrooms",  default: 0
#    t.integer  "number_singles"
#    t.integer  "number_doubles"
#    t.integer  "number_washers"
#    t.integer  "seniors",           default: 0
#    t.integer  "juniors",           default: 0
#    t.integer  "sophomores",        default: 0
#    t.integer  "freshmen",          default: 0
#    t.float    "comfort"
#    t.float    "loudness"
#    t.float    "convenience"
#    t.datetime "created_at"
#    t.datetime "updated_at"
    t.string   "neighborhood_name" #unused
#    t.text     "description"
#    t.integer  "capacity",          default: 0
#    t.float    "bathroom_ratio",    default: 100.0
#    t.float    "wifi"
#    t.float    "location"
#    t.string   "key_or_card"
#    t.float    "satisfaction"
  end

  create_table "discussions", force: true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_active"
    t.string   "title"
    t.integer  "number_replies"
    t.integer  "lum_id"
    t.string   "ex_user_name"
    t.boolean  "deleted",        default: false
  end

  create_table "dormtrak_reviews", force: true do |t|
    t.text     "comment"
    t.integer  "building_id"
    t.string   "building_name" #NULL COLUMN
    t.boolean  "lived_here" #NULL COLUMN
    t.integer  "convenience"
    t.integer  "loudness"
    t.integer  "comfort"
    t.string   "room_number" #NULL COLUMN
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "location"
    t.integer  "wifi"
    t.string   "key_or_card"
    t.string   "closet"
    t.string   "flooring"
    t.boolean  "common_room_access"
    t.text     "common_room_desc"
    t.boolean  "thermostat_access"
    t.text     "thermostat_desc"
    t.text     "closet_desc"
    t.text     "outlets_desc"
    t.integer  "number_windows"
    t.text     "noise"
    t.boolean  "bed_adjustable"
    t.integer  "room_id"
    t.boolean  "anonymous"
    t.string   "single_or_double"
    t.string   "faces"
    t.boolean  "private_bathroom"
    t.text     "bathroom_desc"
    t.string   "picture"
    t.integer  "satisfaction"
  end

  create_table "factrak_agreements", force: true do |t|
    t.boolean  "agrees"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "factrak_comment_id"
    t.integer  "user_id"
    t.integer  "factrak_survey_id"
  end

  create_table "factrak_comments", force: true do |t|
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "factrak_professor_id"
    t.integer  "factrak_course_id"
    t.integer  "user_id"
    t.boolean  "flagged",              default: false
  end

  create_table "factrak_courses", force: true do |t|
    t.string  "number"
    t.integer "factrak_department_id"
  end

  create_table "factrak_departments", force: true do |t|
    t.string "name"
    t.string "abbrev", limit: 4
  end

  create_table "factrak_professors", force: true do |t|
    t.string  "name"
    t.string  "unix_id",               limit: 10
    t.integer "factrak_department_id"
  end

  create_table "factrak_surveys", force: true do |t|
    t.integer  "factrak_professor_id"
    t.integer  "factrak_course_id"
    t.boolean  "would_recommend_course"
    t.integer  "course_workload",        limit: 1
    t.integer  "course_stimulating",     limit: 1
    t.boolean  "would_take_another"
    t.integer  "approachability",        limit: 1
    t.integer  "lead_lecture",           limit: 1
    t.integer  "promote_discussion",     limit: 1
    t.integer  "outside_helpfulness",    limit: 1
    t.integer  "user_id"
    t.datetime "created_at"
    t.text     "comment",                limit: 16777215
    t.datetime "updated_at"
    t.boolean  "flagged"
    t.string   "grade_received",         limit: 1
  end

  create_table "games", force: true do |t|
    t.text     "name"
    t.text     "url"
    t.datetime "created_at"
  end

  create_table "hoots", force: true do |t|
    t.text     "content"
    t.datetime "created_at"
    t.text     "nightowl_alias"
    t.text     "nightowl_login"
    t.text     "title"
    t.datetime "expires_at"
  end

  create_table "keywords", force: true do |t|
    t.string "keyword", limit: 100
  end

  create_table "keywords_organizations", id: false, force: true do |t|
    t.integer "keyword_id",      null: false
    t.integer "organization_id", null: false
  end

  add_index "keywords_organizations", ["organization_id"], name: "fk_cp_organization", using: :btree

  create_table "neighborhoods", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "neighborhoods", ["name"], name: "index_neighborhoods_on_name", unique: true, using: :btree

  create_table "nicknames", force: true do |t|
    t.string "nickname", limit: 100, null: false
  end

  create_table "nicknames_users", id: false, force: true do |t|
    t.integer "user_id",     null: false
    t.integer "nickname_id", null: false
  end

  add_index "nicknames_users", ["nickname_id"], name: "fk_cp_nickname", using: :btree

  create_table "nightowls", force: true do |t|
    t.datetime "logged_in"
    t.integer  "person_id"
    t.text     "status"
    t.text     "alias"
    t.text     "aim"
    t.datetime "last_active"
  end

  create_table "organizations", force: true do |t|
    t.string  "name",         limit: 50,  null: false
    t.string  "website",      limit: 100
    t.string  "wiki_page",    limit: 100, null: false
    t.integer "head_officer",             null: false
    t.integer "treasurer",                null: false
    t.integer "webmaster"
  end

  add_index "organizations", ["head_officer"], name: "fk_cp_head_officer", using: :btree
  add_index "organizations", ["treasurer"], name: "fk_cp_treasurer", using: :btree
  add_index "organizations", ["webmaster"], name: "fk_cp_webmaster", using: :btree

  create_table "people", force: true do |t|
    t.text    "name"
    t.text    "login"
    t.integer "number_items", default: 0
  end

  create_table "photos", force: true do |t|
    t.integer  "person_id"
    t.text     "caption"
    t.datetime "created_at"
    t.datetime "approved_at"
    t.datetime "removed_at"
  end

  create_table "posts", force: true do |t|
    t.integer  "user_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.string   "title"
    t.boolean  "deleted",       default: false
    t.string   "ex_user_name"
    t.integer  "lum_id"
    t.integer  "discussion_id"
  end

  create_table "ride_places", force: true do |t|
    t.string   "name",       limit: 100
    t.integer  "uses",                   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rides", force: true do |t|
    t.integer "is_offer"
    t.string  "source",      limit: 100
    t.string  "destination", limit: 100
    t.date    "start_date"
    t.date    "end_date"
    t.integer "spaces"
    t.string  "notes"
    t.integer "user_id"
    t.integer "round_trip",              default: 0
  end

  create_table "rooms", force: true do |t|
    t.string  "number"
    t.string  "closet"
    t.string  "flooring"
    t.boolean "common_room_access"
    t.text    "common_room_desc"
    t.boolean "thermostat_access"
    t.text    "thermostat_desc"
    t.text    "outlets_desc"
    t.string  "key_or_card"
    t.integer "number_windows"
    t.string  "faces"
    t.text    "noise"
    t.boolean "bed_adjustable"
    t.integer "building_id"
    t.string  "single_or_double"
    t.boolean "hc"
    t.boolean "private_bathroom"
    t.integer "floor_number"
    t.integer "area"
    t.boolean "is_walkthrough"
    t.string  "bathroom_desc"
    t.boolean "num_flag"
    t.string  "picture"
  end

  create_table "schema_info", id: false, force: true do |t|
    t.integer "version"
  end

  create_table "scores", force: true do |t|
    t.integer  "points"
    t.integer  "person_id"
    t.integer  "witness_id"
    t.datetime "created_at"
    t.integer  "game_id"
  end

  create_table "sections", force: true do |t|
    t.text    "name"
    t.integer "number_items"
  end

  create_table "sessions", force: true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "sheets", force: true do |t|
    t.datetime "created_at"
    t.datetime "expires_at"
    t.text     "heading"
    t.integer  "nightowl_id"
  end

  create_table "signups", force: true do |t|
    t.integer "sheet_id"
    t.text    "note"
    t.text    "nightowl_alias"
    t.text    "nightowl_login"
    t.integer "nightowl_id"
  end

  create_table "users", force: true do |t|
    t.string   "cell_phone"
    t.string   "campus_phone_ext"
    t.string   "room"
    t.string   "su_box"
    t.string   "unix_id"
    t.string   "wso_id"
    t.string   "williams_email"
    t.string   "home_street"
    t.string   "home_town"
    t.string   "home_zip"
    t.string   "department"
    t.string   "major"
    t.string   "building"
    t.string   "entry"
    t.string   "title"
    t.string   "class_year"
    t.string   "home_state"
    t.string   "home_country"
    t.boolean  "is_admin"
    t.boolean  "factrak_admin"
    t.boolean  "has_accepted_factrak_policy"
    t.boolean  "visible"
    t.boolean  "home_visible"
    t.string   "alumni_id"
    t.boolean  "is_alumni"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "home_phone"
    t.string   "neighborhood"
    t.boolean  "has_accepted_dormtrak_policy"
    t.boolean  "dorm_visible"
    t.boolean  "has_new_picture"
    t.text     "ephcatches"
  end

end

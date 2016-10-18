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

ActiveRecord::Schema.define(version: 20151223054724) do

  create_table "api_keys", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "access_token"
    t.integer  "expires_at"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "bulletins", force: :cascade do |t|
    t.string   "type",        limit: 255
    t.integer  "user_id",     limit: 4
    t.string   "title",       limit: 127
    t.text     "body",        limit: 65535
    t.datetime "start_date"
    t.boolean  "offer",       limit: 1
    t.string   "source",      limit: 255
    t.string   "destination", limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "courses", force: :cascade do |t|
    t.string   "number",           limit: 255
    t.integer  "area_of_study_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "departments", force: :cascade do |t|
    t.string "name",   limit: 255
  end

  create_table "areas_of_study", force: :cascade do |t|
    t.string "name",           limit: 255
    t.string "abbrev",         limit: 4
    t.integer "department_id", limit: 4
  end

  create_table "discussions", force: :cascade do |t|
    t.integer  "user_id",      limit: 4
    t.datetime "last_active"
    t.string   "title",        limit: 255
    t.integer  "lum_id",       limit: 4
    t.string   "ex_user_name", limit: 255
    t.boolean  "deleted",      limit: 1,   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "discussions", ["user_id"], name: "index_discussions_on_user_id"

  create_table "dormtrak_reviews", force: :cascade do |t|
    t.integer  "user_id",            limit: 4
    t.text     "comment",            limit: 65535
    t.boolean  "lived_here",         limit: 1
    t.string   "closet",             limit: 255
    t.text     "closet_desc",        limit: 65535
    t.string   "flooring",           limit: 255
    t.boolean  "common_room_access", limit: 1
    t.text     "common_room_desc",   limit: 65535
    t.boolean  "thermostat_access",  limit: 1
    t.text     "thermostat_desc",    limit: 65535
    t.text     "outlets_desc",       limit: 65535
    t.string   "key_or_card",        limit: 255    
    t.text     "noise",              limit: 65535
    t.boolean  "bed_adjustable",     limit: 1
    t.boolean  "anonymous",          limit: 1
    t.string   "faces",              limit: 255
    t.boolean  "private_bathroom",   limit: 1
    t.text     "bathroom_desc",      limit: 65535
    t.string   "picture",            limit: 255
    t.integer  "comfort",            limit: 4
    t.integer  "loudness",           limit: 4
    t.integer  "convenience",        limit: 4
    t.float    "wifi",               limit: 24
    t.float    "location",           limit: 24
    t.float    "satisfaction",       limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "dorm_room_id"
  end

  create_table "dorms", force: :cascade do |t|
    t.integer  "neighborhood_id",  limit: 4
    t.string   "name",             limit: 255
    t.string   "key_or_card",      limit: 255
    t.text     "description",      limit: 65535
    t.integer  "built",            limit: 4
    t.integer  "capacity",         limit: 4
    t.integer  "number_bathrooms", limit: 4
    t.integer  "number_singles",   limit: 4
    t.integer  "number_doubles",   limit: 4
    t.integer  "number_washers",   limit: 4
    t.float    "bathroom_ratio",   limit: 24
    t.integer  "comfort",          limit: 4
    t.integer  "loudness",         limit: 4
    t.integer  "convenience",      limit: 4
    t.float    "wifi",             limit: 24
    t.float    "location",         limit: 24
    t.float    "satisfaction",     limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "average_single_area"
    t.integer  "average_double_area"
    t.integer  "mode_single_area"
    t.integer  "mode_double_area"
  end

  create_table "dorm_rooms", force: :cascade do |t|
    t.integer  "dorm_id",        limit: 4
    t.string   "number",             limit: 255
    t.string   "closet",             limit: 255
    t.string   "flooring",           limit: 255
    t.boolean  "common_room_access", limit: 1
    t.text     "common_room_desc",   limit: 65535
    t.boolean  "thermostat_access",  limit: 1
    t.text     "thermostat_desc",    limit: 65535
    t.text     "outlets_desc",       limit: 65535
    t.string   "key_or_card",        limit: 255
    t.string   "faces",              limit: 255
    t.text     "noise",              limit: 65535
    t.boolean  "bed_adjustable",     limit: 1
    t.integer  "capacity",           limit: 4,     default: 1
    t.boolean  "hc",                 limit: 1
    t.boolean  "private_bathroom",   limit: 1
    t.integer  "floor_number",       limit: 4
    t.integer  "area",               limit: 4
    t.boolean  "walkthrough",        limit: 1
    t.text     "bathroom_desc",      limit: 65535
    t.boolean  "num_flag",           limit: 1
    t.string   "picture",            limit: 255
    t.float    "comfort",            limit: 24
    t.float    "loudness",           limit: 24
    t.float    "convenience",        limit: 24
    t.float    "wifi",               limit: 24
    t.float    "location",           limit: 24
    t.float    "satisfaction",       limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dorm_rooms", ["dorm_id"], name: "index_dorm_rooms_on_dorm_id"

  add_index "dormtrak_reviews", ["dorm_room_id"], name: "index_dormtrak_reviews_on_dorm_room_id"
  add_index "dormtrak_reviews", ["user_id"], name: "index_dormtrak_reviews_on_user_id"

  create_table "ephcatches", force: :cascade do |t|
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "user_id",    limit: 4
    t.integer  "other_id",   limit: 4
  end

  create_table "factrak_agreements", force: :cascade do |t|
    t.boolean  "agrees",            limit: 1
    t.integer  "factrak_survey_id", limit: 4
    t.integer  "user_id",           limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "factrak_agreements", ["factrak_survey_id"], name: "index_factrak_agreements_on_factrak_survey_id"
  add_index "factrak_agreements", ["user_id"], name: "index_factrak_agreements_on_user_id"

  create_table "factrak_surveys", force: :cascade do |t|
    t.integer  "professor_id",           limit: 4
    t.integer  "course_id",              limit: 4
    t.boolean  "would_recommend_course", limit: 1
    t.integer  "course_workload",        limit: 4
    t.integer  "course_stimulating",     limit: 4
    t.boolean  "would_take_another",     limit: 1
    t.integer  "approachability",        limit: 4
    t.integer  "lead_lecture",           limit: 4
    t.integer  "promote_discussion",     limit: 4
    t.integer  "outside_helpfulness",    limit: 4
    t.integer  "user_id",                limit: 4
    t.text     "comment",                limit: 65535
    t.boolean  "flagged",                limit: 1
    t.string   "grade_received",         limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "factrak_surveys", ["course_id"], name: "index_factrak_surveys_on_course_id"
  add_index "factrak_surveys", ["professor_id"], name: "index_factrak_surveys_on_professor_id"
  add_index "factrak_surveys", ["user_id"], name: "index_factrak_surveys_on_user_id"

  create_table "neighborhoods", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  
  create_table "offices", force: :cascade do |t|
    t.string   "number",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"    
  end

  create_table "posts", force: :cascade do |t|
    t.integer  "user_id",       limit: 4
    t.text     "content",       limit: 65535
    t.string   "title",         limit: 255
    t.boolean  "deleted",       limit: 1,     default: false
    t.string   "ex_user_name",  limit: 255
    t.integer  "lum_id",        limit: 4
    t.integer  "discussion_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "posts", ["user_id"], name: "index_posts_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "type",                         limit: 255
    t.string   "name",                         limit: 255
    t.string   "cell_phone",                   limit: 255
    t.string   "campus_phone_ext",             limit: 255
    t.string   "unix_id",                      limit: 255
    t.string   "williams_email",               limit: 255
    t.string   "title",                        limit: 255
    t.boolean  "visible",                      limit: 1
    t.integer  "class_year",                   limit: 4
    t.integer  "department_id",                limit: 4
    t.boolean  "dorm_visible",                 limit: 1,   default: true
    t.string   "home_town",                    limit: 255
    t.string   "home_zip",                     limit: 255
    t.string   "home_phone",                   limit: 255
    t.string   "home_state",                   limit: 255
    t.string   "home_country",                 limit: 255
    t.boolean  "home_visible",                 limit: 1,   default: true
    t.string   "major",                        limit: 255
    t.string   "su_box",                       limit: 255
    t.string   "entry",                        limit: 255
    t.boolean  "admin",                        limit: 1,   default: false
    t.boolean  "factrak_admin",                limit: 1,   default: false
    t.boolean  "has_accepted_factrak_policy",  limit: 1,   default: false
    t.boolean  "has_accepted_dormtrak_policy", limit: 1,   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "office_id"
    t.integer  "dorm_room_id"
    t.string   "search_fields"
  end

  add_index "users", ["dorm_room_id"], name: "index_rooms_on_dorm_room_id"

end

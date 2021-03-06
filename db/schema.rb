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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120712174323) do

  create_table "alerts", :force => true do |t|
    t.integer  "commit_id"
    t.string   "file"
    t.string   "klass"
    t.string   "function"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "alerts", ["commit_id"], :name => "index_alerts_on_commit_id"

  create_table "bug_fixes", :force => true do |t|
    t.integer  "commit_id"
    t.string   "file"
    t.string   "klass"
    t.string   "function"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.date     "date_fixed"
  end

  add_index "bug_fixes", ["commit_id"], :name => "index_bug_fixes_on_commit_id"

  create_table "clues", :force => true do |t|
    t.integer  "commit_id"
    t.integer  "mystery_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "clues", ["commit_id"], :name => "index_clues_on_commit_id"
  add_index "clues", ["mystery_id"], :name => "index_clues_on_mystery_id"

  create_table "commits", :force => true do |t|
    t.string   "sha"
    t.integer  "repo_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "user_id"
    t.float    "complexity"
    t.datetime "date"
  end

  add_index "commits", ["sha"], :name => "index_commits_on_sha", :unique => true

  create_table "defects", :force => true do |t|
    t.string   "priority"
    t.string   "title"
    t.string   "ticket_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "type"
    t.integer  "status"
    t.integer  "repo_id"
    t.datetime "date"
  end

  create_table "mysteries", :force => true do |t|
    t.string   "exception_type"
    t.string   "backtrace"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "releases", :force => true do |t|
    t.integer  "repo_id"
    t.string   "sha"
    t.datetime "deploy_date"
    t.string   "env"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "releases", ["repo_id"], :name => "index_releases_on_repo_id"

  create_table "repos", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "subscriptions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "repo_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.boolean  "notify_on_analysis", :default => false
  end

  add_index "subscriptions", ["repo_id"], :name => "index_subscriptions_on_repo_id"
  add_index "subscriptions", ["user_id"], :name => "index_subscriptions_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "name"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "identifier_url"
  end

  add_index "users", ["identifier_url"], :name => "index_users_on_identifier_url", :unique => true

end

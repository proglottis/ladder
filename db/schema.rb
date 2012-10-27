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

ActiveRecord::Schema.define(:version => 20121027224905) do

  create_table "game_ranks", :force => true do |t|
    t.integer  "rank_id",      :null => false
    t.integer  "game_id",      :null => false
    t.integer  "position",     :null => false
    t.datetime "confirmed_at"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "game_ranks", ["game_id"], :name => "index_game_ranks_on_game_id"
  add_index "game_ranks", ["rank_id"], :name => "index_game_ranks_on_rank_id"

  create_table "games", :force => true do |t|
    t.integer  "tournament_id", :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "games", ["tournament_id"], :name => "index_games_on_tournament_id"

  create_table "invites", :force => true do |t|
    t.integer  "user_id"
    t.integer  "tournament_id"
    t.string   "code",          :null => false
    t.string   "email",         :null => false
    t.datetime "expires_at",    :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "invites", ["code"], :name => "index_invites_on_code"
  add_index "invites", ["tournament_id"], :name => "index_invites_on_tournament_id"
  add_index "invites", ["user_id"], :name => "index_invites_on_user_id"

  create_table "ranks", :force => true do |t|
    t.integer  "user_id",                                       :null => false
    t.integer  "tournament_id",                                 :null => false
    t.decimal  "mu",            :precision => 38, :scale => 10, :null => false
    t.decimal  "sigma",         :precision => 38, :scale => 10, :null => false
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
  end

  add_index "ranks", ["tournament_id"], :name => "index_ranks_on_tournament_id"
  add_index "ranks", ["user_id"], :name => "index_ranks_on_user_id"

  create_table "services", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "services", ["provider"], :name => "index_services_on_provider"
  add_index "services", ["uid"], :name => "index_services_on_uid"
  add_index "services", ["user_id"], :name => "index_services_on_user_id"

  create_table "tournaments", :force => true do |t|
    t.string   "name",       :null => false
    t.integer  "owner_id",   :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end

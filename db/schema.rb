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

ActiveRecord::Schema.define(version: 20171019063842) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "applications", force: :cascade do |t|
    t.string "name", null: false
    t.integer "tournament_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tournament_id"], name: "index_applications_on_tournament_id"
  end

  create_table "championship_players", force: :cascade do |t|
    t.integer "championship_id", null: false
    t.integer "player_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["championship_id", "player_id"], name: "index_championship_players_on_championship_id_and_player_id", unique: true
    t.index ["championship_id"], name: "index_championship_players_on_championship_id"
    t.index ["player_id"], name: "index_championship_players_on_player_id"
  end

  create_table "championships", force: :cascade do |t|
    t.integer "tournament_id", null: false
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["tournament_id"], name: "index_championships_on_tournament_id"
  end

  create_table "comments", force: :cascade do |t|
    t.integer "commentable_id", null: false
    t.string "commentable_type", limit: 255, null: false
    t.text "content"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", limit: 255, null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope", limit: 255
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "game_events", force: :cascade do |t|
    t.integer "game_id"
    t.string "state", limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["game_id"], name: "index_game_events_on_game_id"
  end

  create_table "game_ranks", force: :cascade do |t|
    t.integer "game_id", null: false
    t.integer "position"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "player_id", null: false
    t.index ["game_id", "player_id"], name: "index_game_ranks_on_game_id_and_player_id", unique: true
    t.index ["game_id"], name: "index_game_ranks_on_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.integer "tournament_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "confirmed_at"
    t.integer "owner_id", null: false
    t.index ["owner_id"], name: "index_games_on_owner_id"
    t.index ["tournament_id"], name: "index_games_on_tournament_id"
  end

  create_table "invite_requests", force: :cascade do |t|
    t.integer "tournament_id", null: false
    t.integer "user_id", null: false
    t.integer "invite_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "completed_at"
    t.index ["tournament_id", "user_id"], name: "index_invite_requests_on_tournament_id_and_user_id", unique: true
  end

  create_table "invites", force: :cascade do |t|
    t.integer "user_id"
    t.integer "tournament_id"
    t.string "code", limit: 255, null: false
    t.string "email", limit: 255, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "owner_id", null: false
    t.index ["code"], name: "index_invites_on_code"
    t.index ["owner_id"], name: "index_invites_on_owner_id"
    t.index ["tournament_id"], name: "index_invites_on_tournament_id"
    t.index ["user_id"], name: "index_invites_on_user_id"
  end

  create_table "matches", force: :cascade do |t|
    t.integer "championship_id", null: false
    t.integer "bracket", null: false
    t.integer "player1_id"
    t.integer "player2_id"
    t.integer "game_id"
    t.integer "winners_match_id"
    t.integer "losers_match_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["championship_id"], name: "index_matches_on_championship_id"
    t.index ["game_id"], name: "index_matches_on_game_id"
  end

  create_table "pages", force: :cascade do |t|
    t.text "content"
    t.integer "parent_id"
    t.string "parent_type", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_pages_on_parent_id"
    t.index ["parent_type"], name: "index_pages_on_parent_type"
  end

  create_table "players", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "tournament_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "winning_streak_count", default: 0, null: false
    t.integer "losing_streak_count", default: 0, null: false
    t.datetime "end_at"
    t.integer "position"
    t.index ["tournament_id"], name: "index_players_on_tournament_id"
    t.index ["user_id", "tournament_id"], name: "index_players_on_user_id_and_tournament_id", unique: true
    t.index ["user_id"], name: "index_players_on_user_id"
  end

  create_table "push_notification_keys", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "gcm"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_push_notification_keys_on_user_id"
  end

  create_table "rating_periods", force: :cascade do |t|
    t.integer "tournament_id", null: false
    t.datetime "period_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["period_at"], name: "index_rating_periods_on_period_at"
    t.index ["tournament_id"], name: "index_rating_periods_on_tournament_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.integer "rating_period_id", null: false
    t.decimal "rating", precision: 38, scale: 10, null: false
    t.decimal "rating_deviation", precision: 38, scale: 10, null: false
    t.decimal "volatility", precision: 38, scale: 10, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "player_id", null: false
    t.index ["rating_period_id", "player_id"], name: "index_ratings_on_rating_period_id_and_player_id", unique: true
    t.index ["rating_period_id"], name: "index_ratings_on_rating_period_id"
  end

  create_table "services", force: :cascade do |t|
    t.integer "user_id"
    t.string "provider", limit: 255
    t.string "uid", limit: 255
    t.string "name", limit: 255
    t.string "email", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name", limit: 255
    t.string "last_name", limit: 255
    t.string "image_url", limit: 255
    t.index ["provider"], name: "index_services_on_provider"
    t.index ["uid"], name: "index_services_on_uid"
    t.index ["user_id"], name: "index_services_on_user_id"
  end

  create_table "tournaments", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.integer "owner_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug", limit: 255
    t.boolean "public", default: false, null: false
    t.string "ranking_type", default: "glicko2", null: false
    t.string "domain"
    t.index ["public"], name: "index_tournaments_on_public"
    t.index ["slug"], name: "index_tournaments_on_slug", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name", limit: 255
    t.string "email", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "preferred_service_id"
    t.boolean "game_confirmed_email", default: true, null: false
    t.boolean "commented_email", default: true, null: false
    t.string "slug", limit: 255
    t.boolean "game_unconfirmed_email", default: true, null: false
    t.index ["preferred_service_id"], name: "index_users_on_preferred_service_id"
    t.index ["slug"], name: "index_users_on_slug", unique: true
  end

end

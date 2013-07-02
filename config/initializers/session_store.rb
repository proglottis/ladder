# Be sure to restart your server when you modify this file.

Ladder::Application.config.session_store ActionDispatch::Session::CacheStore, :expire_after => 7.day

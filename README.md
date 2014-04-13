# Ladder

Ladder tournament ranking website. Uses Glicko2 to rank players of pool, foosball, or any other 1 vs 1 game and track their skill over time.

## Getting Started

Clone the repository and install gems.
```
git clone https://github.com/proglottis/ladder.git
cd ladder
bundle install
```

Create `config/secrets.yml` from the example file `config/secrets.yml.example`. If you are only running ladder locally these values can be left at their defaults.

Create `config/database.yml` from the example file `config/database.yml.example`.

Setup the database. _Do not run migrations from the start of time, doing so will fail._
```
bundle exec rake db:setup
```

For development the "developer" strategy is enabled on OmniAuth. This will accept any values for authentication.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

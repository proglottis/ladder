Ladder.Router.map ->
  @route('tournaments.new', { path: '/tournaments/new' })
  @resource('tournament', { path: '/tournaments/:tournament_id' }, ->
    @resource('ratings')
  )
  @resource('game', { path: '/games/:game_id' })

Ladder.IndexRoute = Ember.Route.extend
  setupController: ->
    @controllerFor('tournaments').set('model', Ladder.Tournament.find())
    @controllerFor('games').set('model', Ladder.Game.find())

Ladder.TournamentsNewRoute = Ember.Route.extend
  model: ->
    transaction = @get('store').transaction()
    transaction.createRecord(Ladder.Tournament, {})

  deactivate: ->
    @modelFor("tournaments.new").get("transaction").rollback()

Ladder.TournamentIndexRoute = Ember.Route.extend
  redirect: ->
    @transitionTo('ratings')

Ladder.RatingsRoute = Ember.Route.extend
  model: ->
    @modelFor("tournament").get("currentRatingPeriod.ratings")

  setupController: ->
    @controllerFor('ratingPeriod').set('model', @modelFor("tournament").get("currentRatingPeriod"))

Ladder.GameRoute = Ember.Route.extend
  setupController: ->
    @controllerFor('gameRanks').set('model', @get('model.gameRanks'))

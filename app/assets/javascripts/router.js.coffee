Ladder.Router.map ->
  @route('tournaments.new', { path: '/tournaments/new' })
  @resource('tournament', { path: '/tournaments/:tournament_id' }, ->
    @resource('ratings')
  )

Ladder.IndexRoute = Ember.Route.extend
  setupController: ->
    @controllerFor('tournaments').set('model', Ladder.Tournament.find())
    @controllerFor('games').set('model', Ladder.Game.find())

Ladder.TournamentIndexRoute = Ember.Route.extend
  redirect: ->
    @transitionTo('ratings')

Ladder.RatingsRoute = Ember.Route.extend
  model: ->
    @modelFor("tournament").get("ratings")

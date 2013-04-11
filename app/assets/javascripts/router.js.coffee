Ladder.Router.map ->
  this.resource('tournament', { path: '/tournaments/:tournament_id' })

Ladder.IndexRoute = Ember.Route.extend
  setupController: ->
    @controllerFor('tournaments').set('model', Ladder.Tournament.find())
    @controllerFor('games').set('model', Ladder.Game.find())

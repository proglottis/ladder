Ladder.Router.map ->

Ladder.IndexRoute = Ember.Route.extend
  setupController: ->
    @controllerFor('tournaments').set('model', Ladder.Tournament.find())

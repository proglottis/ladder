Ladder.TournamentsNewController = Ember.Controller.extend
  create: ->
    tournament = Ladder.Tournament.createRecord
      name: @get('name')
    @get('store').commit()
    false

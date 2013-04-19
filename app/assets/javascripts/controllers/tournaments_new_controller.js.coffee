Ladder.TournamentsNewController = Ember.Controller.extend
  create: ->
    @get('model.transaction').commit()
    false

  transitionAfterCreate: (->
    if @get('model.id')
      @transitionToRoute('tournament', @get('model'))
  ).observes('model.id')

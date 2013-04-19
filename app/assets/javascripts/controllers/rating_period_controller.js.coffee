Ladder.RatingPeriodController = Ember.ObjectController.extend
  nextPeriodAt: (->
    moment(@get('periodAt')).add('days', 7)
  ).property('periodAt')

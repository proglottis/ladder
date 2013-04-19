Ladder.RatingsController = Ember.ArrayController.extend
  needs: 'ratingPeriod'
  sortProperties: ['lowRank']
  sortAscending: false

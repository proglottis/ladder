Ladder.RatingsController = Ember.ArrayController.extend
  needs: 'ratingPeriod'
  itemController: 'rating'
  sortProperties: ['lowRank']
  sortAscending: false

  byRank: (->
    n = 0
    last = null
    @map (rating) ->
      n += 1 unless last && last.get('lowRank') == rating.get('lowRank')
      rating.set('rank', n)
      last = rating
      rating
  ).property('@each.low_rank')

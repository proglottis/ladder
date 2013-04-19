Ladder.RatingController = Ember.ObjectController.extend
  isCurrentUser: (->
    @get('currentUser.id') == @get('user.id')
  ).property('currentUser.id')

Ladder.Tournament = DS.Model.extend
  name: DS.attr('string')
  currentRatingPeriod: DS.belongsTo('Ladder.RatingPeriod')
  createdAt: DS.attr('date')
  updatedAt: DS.attr('date')

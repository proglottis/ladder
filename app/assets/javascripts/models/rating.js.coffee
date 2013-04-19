Ladder.Rating = DS.Model.extend
  ratingPeriod: DS.belongsTo('Ladder.RatingPeriod')
  user: DS.belongsTo('Ladder.User')
  lowRank: DS.attr('number')

Ladder.Tournament = DS.Model.extend
  name: DS.attr('string')
  currentRatingPeriod: DS.belongsTo('Ladder.RatingPeriod')
  pages: DS.hasMany('Ladder.Page')
  page: DS.belongsTo('Ladder.Page')
  createdAt: DS.attr('date')
  updatedAt: DS.attr('date')

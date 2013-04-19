Ladder.RatingPeriod = DS.Model.extend
  tournament: DS.belongsTo('Ladder.Tournament')
  ratings: DS.hasMany('Ladder.Rating')
  periodAt: DS.attr('date')
  createdAt: DS.attr('date')
  updatedAt: DS.attr('date')

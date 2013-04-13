Ladder.Tournament = DS.Model.extend
  name: DS.attr('string')
  createdAt: DS.attr('date')
  updatedAt: DS.attr('date')
  ratings: DS.hasMany('Ladder.Rating')

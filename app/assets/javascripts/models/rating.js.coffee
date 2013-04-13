Ladder.Rating = DS.Model.extend
  tournament: DS.belongsTo('Ladder.Tournament')
  user: DS.belongsTo('Ladder.User')
  lowRank: DS.attr('number')

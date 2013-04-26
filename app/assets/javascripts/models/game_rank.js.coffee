Ladder.GameRank = DS.Model.extend
  game: DS.belongsTo('Ladder.Game')
  user: DS.belongsTo('Ladder.User')
  confirmedAt: DS.attr('date')
  position: DS.attr('number')
  createdAt: DS.attr('date')
  updatedAt: DS.attr('date')

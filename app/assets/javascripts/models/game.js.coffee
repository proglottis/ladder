Ladder.Game = DS.Model.extend
  versus: DS.attr('string')
  imageUrl: DS.attr('string')
  tournament: DS.belongsTo('Ladder.Tournament')
  confirmedAt: DS.attr('date')
  createdAt: DS.attr('date')
  updatedAt: DS.attr('date')

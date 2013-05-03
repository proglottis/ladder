Ladder.Page = DS.Model.extend
  content: DS.attr('string')
  tournament: DS.belongsTo('Ladder.Tournament')
  createdAt: DS.attr('date')
  updatedAt: DS.attr('date')

Ember.Handlebars.registerBoundHelper('date', (date) ->
  moment(date).format('LLL')
)

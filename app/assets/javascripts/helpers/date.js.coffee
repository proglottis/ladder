Ember.Handlebars.registerBoundHelper('date', (date) ->
  moment(date).format('LLL')
)

Ember.Handlebars.registerBoundHelper('fromNow', (date) ->
  moment(date).fromNow()
)

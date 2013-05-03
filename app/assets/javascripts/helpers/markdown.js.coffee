converter = new Showdown.converter()

Ember.Handlebars.registerBoundHelper('markdown', (text) ->
  new Handlebars.SafeString converter.makeHtml(text)
)

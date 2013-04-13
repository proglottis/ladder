Ember.Handlebars.registerBoundHelper('image', (url) ->
  escaped = Handlebars.Utils.escapeExpression(url)
  new Handlebars.SafeString '<img width="16" height="16" src="' + escaped + '"/>'
)

Ember.Handlebars.registerBoundHelper('largeImage', (url) ->
  escaped = Handlebars.Utils.escapeExpression(url)
  new Handlebars.SafeString '<img width="64" height="64" src="' + escaped + '"/>'
)

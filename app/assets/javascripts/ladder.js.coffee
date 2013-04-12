//= require ./store
//= require_tree ./models
//= require_tree ./controllers
//= require_tree ./views
//= require_tree ./helpers
//= require_tree ./templates
//= require ./router
//= require_tree ./routes
//= require_self

Ember.Application.initializer
  name: "currentUser"
  initialize: (container, application) ->
    store = container.lookup('store:main')
    attributes = $('body').attr('data-current-user');
    return unless attributes
    obj = store.load(Ladder.User, $.parseJSON(attributes))
    user = Ladder.User.find(obj.id)
    controller = container.lookup('controller:currentUser').set('content', user)
    container.typeInjection('controller', 'currentUser', 'controller:currentUser')

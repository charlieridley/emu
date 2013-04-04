// Copied from https://github.com/emberjs/data/blob/master/packages/ember-data/lib/system/application_ext.js
var set = Ember.set;
Ember.onLoad('Ember.Application', function(Application) {
  if (Application.registerInjection) {
    Application.registerInjection({
      name: "store",
      before: "controllers",    
      injection: function(app, stateManager, property) {
        if (!stateManager) { return; }
        if (property === 'Store') {
          set(stateManager, 'store', app[property].create());
        }
      }
    });

    Application.registerInjection({
      name: "giveStoreToControllers",
      after: ['store','controllers'],
      injection: function(app, stateManager, property) {
        if (!stateManager) { return; }
        if (/^[A-Z].*Controller$/.test(property)) {
          var controllerName = property.charAt(0).toLowerCase() + property.substr(1);
          var store = stateManager.get('store');
          var controller = stateManager.get(controllerName);
          if(!controller) { return; }

          controller.set('store', store);
        }
      }
    });
  } else if (Application.initializer) {
    Application.initializer({
      name: "store",

      initialize: function(container, application) {
        application.register('store:main', application.Store);
        container.lookup('store:main');
      }
    });

    Application.initializer({
      name: "injectStore",

      initialize: function(container, application) {
        application.inject('controller', 'store', 'store:main');
        application.inject('route', 'store', 'store:main');
      }
    });
  }
});

# Copied from https://github.com/emberjs/data/blob/master/packages/ember-data/lib/system/application_ext.js
set = Ember.set
Ember.onLoad "Ember.Application", (Application) ->
  if Application.registerInjection
    Application.registerInjection
      name: "store"
      before: "controllers"
      injection: (app, stateManager, property) ->
        return unless stateManager
        set stateManager, "store", app[property].create() if property is "Store"

    Application.registerInjection
      name: "giveStoreToControllers"
      after: ["store", "controllers"]
      injection: (app, stateManager, property) ->
        return unless stateManager
        if /^[A-Z].*Controller$/.test(property)
          controllerName = property.charAt(0).toLowerCase() + property.substr(1)
          store = stateManager.get("store")
          controller = stateManager.get(controllerName)
          return  unless controller
          controller.set "store", store

  else if Application.initializer
    Application.initializer
      name: "store"
      initialize: (container, application) ->
        application.register "store:main", application.Store
        container.lookup "store:main"

    Application.initializer
      name: "injectStore"
      initialize: (container, application) ->
        application.inject "controller", "store", "store:main"
        application.inject "route", "store", "store:main"
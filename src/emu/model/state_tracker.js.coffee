Emu.StateTracker = Ember.Object.extend
  track: (model) ->
    model.on "didStartLoading", ->
      model.set("isLoading", true)
      model.set("isLoaded", false)

    model.on "didFinishLoading", ->
      model.set("isLoading", false)
      model.set("isLoaded", true)
      model.set("isDirty", false)
      model.set("isSaved", true)

    model.on "didStartSaving", ->
      model.set("isSaving", true)

    model.on "didFinishSaving", ->
      model.set("isSaving", false)
      model.set("isDirty", false)
      model.set("isLoaded", true)
      model.set("isSaved", true)

    model.on "didStateChange", ->
      model.set("isDirty", true)

    model.on "didError", ->
      model.set("isDirty", true)
      model.set("isLoaded", false)
      model.set("isLoading", false)
      model.set("isSaving", false)
      model.set("isError", true)
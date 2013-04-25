Emu.ModelEvented = Ember.Mixin.create
  didStartLoading: -> @trigger("didStartLoading")
  didFinishLoading: -> @trigger("didFinishLoading")
  didStartSaving: -> @trigger("didStartSaving")
  didFinishSaving: -> @trigger("didFinishSaving")
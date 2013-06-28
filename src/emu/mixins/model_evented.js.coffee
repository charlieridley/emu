Emu.ModelEvented = Ember.Mixin.create
  didStartLoading: -> @trigger("didStartLoading")
  didFinishLoading: -> @trigger("didFinishLoading")
  didFinishPartialLoading: -> @trigger("didFinishPartialLoading")
  didStartSaving: -> @trigger("didStartSaving")
  didFinishSaving: -> @trigger("didFinishSaving")
  didStateChange: -> @trigger("didStateChange")
  didError: -> @trigger("didError")
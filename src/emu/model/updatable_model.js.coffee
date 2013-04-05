Emu.UpdatableModel = Emu.Model.extend
  init: ->
    Emu.updatableTypes ?= []
    Emu.updatableTypes.pushObject(@constructor)
    @get("store").registerUpdatable(this)
    
Emu.UpdatableModel.reopenClass
  isUpdatable: true
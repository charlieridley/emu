App.UpdatablePerson = Emu.Model.extend
  name: Emu.field("string")

App.ProcessingJob = Emu.Model.extend
  tasks: Emu.field("App.Task", {collection: true})

App.Task = Emu.Model.extend
  message: Emu.field("string")
  completed: Emu.field("boolean")
App.Address = Emu.Model.extend
  town: Emu.field("string") 

App.Person = Emu.Model.extend
  name: Emu.field("string")
  address: Emu.field("App.Address")

App.CustomPerson = App.Person.extend
  personId: Emu.field("string", {primaryKey: true})

App.Order = Emu.Model.extend
  orderCode: Emu.field("string")

App.Customer = Emu.Model.extend
  name: Emu.field("string")
  orders: Emu.field("App.Order", {collection: true, lazy: true})
  addresses: Emu.field("App.Address", {collection: true})
  town: Emu.field("string", {partial: true})  

App.ClubTropicana = Emu.Model.extend
  drinksAreFree: Emu.field("string")
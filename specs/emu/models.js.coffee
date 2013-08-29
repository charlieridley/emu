App.Address = Emu.Model.extend
  town: Emu.field("string")
App.Address.reopenClass(resourceName: 'addresses')

App.Person = Emu.Model.extend
  name: Emu.field("string")
  address: Emu.field("App.Address")

App.Person.reopenClass(resourceName: 'people')

App.CustomPerson = App.Person.extend
  personId: Emu.field("string", {primaryKey: true})

App.CustomPerson.reopenClass(resourceName:(isSingular) -> if isSingular then 'custom_person' else 'custom_people')

App.Order = Emu.Model.extend
  orderCode: Emu.field("string")
  customer: Emu.field("App.Customer")

App.Customer = Emu.Model.extend
  name: Emu.field("string")
  orders: Emu.field("App.Order", {collection: true, lazy: true})
  addresses: Emu.field("App.Address", {collection: true})
  town: Emu.field("string", {partial: true})

App.ClubTropicana = Emu.Model.extend
  drinksAreFree: Emu.field("string")

App.Organization = Emu.Model.extend
  name: Emu.field('string')
  projects: Emu.field('App.Project', {collection: true, lazy: true})

App.Project = Emu.Model.extend
  name: Emu.field('string')
  organization: Emu.field('App.Organization')

App.Report = Emu.Model.extend
  title: Emu.field("string")
  records: Emu.field("App.ReportRecord", {collection: true, paged: true})

App.ReportRecord = Emu.Model.extend
  value: Emu.field("number")

App.Student = Emu.Model.extend
  name: Emu.field("string")
  teacher: Emu.field("App.Teacher", {lazy: true})

App.Teacher = Emu.Model.extend
  name: Emu.field("string")
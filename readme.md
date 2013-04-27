#Emu [![Build Status](https://secure.travis-ci.org/charlieridley/emu.png?branch=master)](https://travis-ci.org/charlieridley/emu)

Emu is a simple data access library for [Ember.js](http://www.emberjs.com).

To Start
--------
```javascript
// you need a store
App.Store = Emu.Store.extend();

// lets define some models
App.Company = Emu.Model.extend({
	name: Emu.field("string"),
	address: Emu.field("App.Address", {partial: true}),	
	employees: Emu.field("App.Employee", {collection: true, lazy: true})
});

App.Address = Emu.Model.extend({
	street: Emu.field("string"),
	town: Emu.field("string")
});

App.Employee = Emu.Model.extend({
	employeeId: Emu.field("string", {primaryKey: true}), //custom primary key, overrides default 'id' field
	name: Emu.field("string")
});
```
Querying
--------
```javascript
var companies = App.Company.find({searchName: "inc", pageNumber: 3, recordCount: 20});
	//GET request to: 	http://www.mysite.com/company?searchName=inc&pageNumber=3&recordCount=20

var companies = App.Company.find(function(company){return company.get("name").indexOf("inc") > 0;});
	//GET request to: 	http://www.mysite.com/company
	//Filters results by function when collection has loaded
```
Partial loading
---------------
```javascript
//Load a bunch of models - each model is "partially" loaded when getting as a collection
var companies = App.Company.find();  
	//GET request to: 	http://www.mysite.com/company
	//Response: [{id: 1, name: "Apple"}, {id: 2, name: "Facebook"}]

//Getting a partial value triggers a full load of the model
companies.get("firstObject.address");
	//GET request to:	http://www.mysite.com/company/1
	//Response: {id: 1, name: "Apple", address: {street:"1 Infinite Loop", town: "Cupertino"}}
```
Lazy loading of collections
------------
```javascript
//Get a lazy collection property
var members = company.get("employees");
	//GET request to:	http://www.mysite.com/company/1/employee
	//Response: [{name: "Tom"}, {name: "Barny"}]
```
Persistence
-----------
```javascript
//Save an existing model
var company = App.Company.find(5);
company.save();
	//PUT request to:	http://www.mysite.com/company/5

//Save a new model
var company = App.Company.createRecord();
company.save();
	//POST request to:	http://www.mysite.com/company
```

Default values
--------------
```javascript
App.Foo = Emu.Model.extend({
	bar: Emu.field("string", {defaultValue: "moo"})
});

var foo = App.Foo.createRecord();
foo.get("bar"); // -> moo
```

Serialization
-------------
The default serializer creates a json representation of the object
```javascript
App.FunnyPerson = Emu.Model.extend({
	firstName: Emu.field("string"),
	lastName: Emu.field("string")
});
```
will serialize to
```javascript
{firstName:"Barry", lastName: "Chuckle"}
```

However, if your backend prefers underscore seperated property names then you can easly switch the serializer when defining your store:

```javascript
App.Store = Emu.Store.extend({
	adapter: Emu.RestAdapter.extend({
		serializer: Emu.UnderscoreSerializer.extend()
	})
})
```

which will serialize to
```javascript
{first_name:"Paul", last_name: "Chuckle"}
```
This will also serialize the URLs with underscores

```
/funny_person?search_term=chuckle
```
Receiving updates from server
----------------------------

This is a bit of an experiment, I think there's a lot of scope for improving this API so it's likely to change.

You can receive updates from your server using the Emu.PushDataAdapter. There is currently a [SignalR](https://github.com/SignalR/SignalR) implementation of this. In order to use this you need to specify your adapter on the store. 

Use SignalR adapter like this:

```javascript
App.Store = Emu.Store.extend({
  pushAdapter: Emu.SignalrPushDataAdapter.extend({
    updatableTypes: ["App.RunningJob"]
  })
});
```
For this example the signalr adapter would look for a hub named 'runningJobHub' with an 'update' method.

You can then subcribe to updates for an object like this:

```javascript
var runningJob = App.RunningJob.find(5);
runningJob.subscribeToUpdates();
runningJob.get("logMessages.firstObject.message"); // -> undefined
//updated received: {id: 5, logMessages: {id: 1, message: "something amazing happened"}}
runningJob.get("logMessages.firstObject.message"); // -> "something amazing happened"
```
You can also specify that you would like all children of a collection to receive updates when defining your model, like this:

```javascript
App.Job = Emu.Model({
  title: Emu.field("string"),
  runningJobs: Emu.field("App.RunningJob", {collection: true, updatable: true})
});
```

You can also make your own PushDataAdapter like this:

```javascript
App.MySpecialPushAdapter = Emu.PushDataAdapter.extend({
  //implement this function to receive updates for a type
  registerForUpdates: function(store, type){
    var _this = this;
    someCallbackThatReceivesAnUpdateForType(type, function(json){
      _this.didUpdate(type, store, json);
    });    
  },
  
  //implement this function for any start code required
  start: function(store){
    this._super(store);
    //Initialization code here	
  }
});
```

Model Events
------------
You can subscribe to certain events on your models:

```javascript
car.on("didStateChange", function(){ alert("hey don't touch that"); });
```
Available events are:
```
didStartLoading
didFinishLoading
didStartSaving
didFinishSaving
didStateChange
didError
```

Model State
-----------
Models contain a few properties to describe their state:

```
isLoaded
isLoading
isSaving
isDirty
isError
```

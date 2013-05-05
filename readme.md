#Emu [![Build Status](https://secure.travis-ci.org/charlieridley/emu.png?branch=master)](https://travis-ci.org/charlieridley/emu)

Emu is a simple data access library for [Ember.js](http://www.emberjs.com).

Breaking Changes
----------------
Breaking changes can be found [here](https://github.com/charlieridley/emu/blob/master/breaking_changes.md)

To Start
--------
```javascript
// you need a store
App.Store = Emu.Store.extend({
  revision: 1
});

// lets define some models
App.Company = Emu.Model.extend({
	resourceName: "companies", //override default which would be 'companys'
	name: Emu.field("string"),
	address: Emu.field("App.Address", {partial: true}),	
	employees: Emu.field("App.Employee", {collection: true, lazy: true})
});

App.Address = Emu.Model.extend({
	resourceName: "addresses",
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
	//GET request to: 	http://www.mysite.com/companies?searchName=inc&pageNumber=3&recordCount=20

var companies = App.Company.find(function(company){return company.get("name").indexOf("inc") > 0;});
	//GET request to: 	http://www.mysite.com/companies
	//Filters results by function when collection has loaded
```
Partial loading
---------------
```javascript
//Load a bunch of models - each model is "partially" loaded when getting as a collection
var companies = App.Company.find();  
	//GET request to: 	http://www.mysite.com/companies
	//Response: [{id: 1, name: "Apple"}, {id: 2, name: "Facebook"}]

//Getting a partial value triggers a full load of the model
companies.get("firstObject.address");
	//GET request to:	http://www.mysite.com/companies/1
	//Response: {id: 1, name: "Apple", address: {street:"1 Infinite Loop", town: "Cupertino"}}
```
Lazy loading of collections
------------
```javascript
//Get a lazy collection property
var members = company.get("employees");
	//GET request to:	http://www.mysite.com/companies/1/employees
	//Response: [{name: "Tom"}, {name: "Barny"}]
```
Persistence
-----------
```javascript
//Save an existing model
var company = App.Company.find(5);
company.save();
	//PUT request to:	http://www.mysite.com/companies/5

//Save a new model
var company = App.Company.createRecord();
company.save();
	//POST request to:	http://www.mysite.com/companies
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

The serializer pluralizes type names by default. To turn this of set the pluralization flag to false:

```javascript
App.Store = Emu.Store.extend({
  adapter: Emu.RestAdapter.extend({
    serializer: Emu.Serializer.extend({pluralization: false})
  })
})
```
To you can specify overrides in your models using a string or a function:

```javascript
App.Person = Emu.Model.extend({
  resourceName: "people"
})

App.Person = Emu.Model.extend({
  resourceName: function(){
    return "people";
  }
})
```
If your backend prefers underscore seperated property names then you can easly switch the serializer when defining your store:

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
/funny_persons?search_term=chuckle
```
Receiving updates from server
----------------------------

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
isSaved
isDirty
isError
```
Pagination
----------
You can load models as a paged collection:
```javascript
var tweets = App.Tweet.findPaged(10);
	//GET request to: /tweets?pageNumber=1&pageSize=10
	//Response: {totalRecordCount: 10000, results: [{id: 1, content: "what a twit"},......]
tweets.loadMore();
	//GET request to: /tweets?pageNumber=2&pageSize=10
	//Response: {totalRecordCount: 10000, results: [{id: 11, content: "blah blah"},......]
```
You can also defined a paged collection as a field of another model:
```javascript
App.Report = Emu.Model({
  title: Emu.field("string"),
  records: Emu.field("App.Record", {collection: true, paged: true})
});

App.Record = Emu.Model({
  year: Emu.field("number"),
  money: Emu.field("number")
});

var report = App.Report.find(5);
records = report.get("records");
	//GET request to: /reports/5/records?pageNumber=1&pageSize=250
	//Response: {totalRecordCount: 5000, results: [{id: 1, year: 1996, money: 1250},......]
records.get("length"); // -> 250
records.loadMore();
	//GET Request to: /reports/5/records?pageNumber=2&pageSize=250
	//Response: {totalRecordCount: 5000, results: [{id: 251, year: 2001, money: 12350},......]
records.get("length"); // -> 500
```

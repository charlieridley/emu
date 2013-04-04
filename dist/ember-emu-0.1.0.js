(function() {
  window.Emu = Ember.Namespace.create();

}).call(this);
(function() {
  var set;

  set = Ember.set;

  Ember.onLoad("Ember.Application", function(Application) {
    if (Application.registerInjection) {
      Application.registerInjection({
        name: "store",
        before: "controllers",
        injection: function(app, stateManager, property) {
          if (!stateManager) {
            return;
          }
          if (property === "Store") {
            return set(stateManager, "store", app[property].create());
          }
        }
      });
      return Application.registerInjection({
        name: "giveStoreToControllers",
        after: ["store", "controllers"],
        injection: function(app, stateManager, property) {
          var controller, controllerName, store;

          if (!stateManager) {
            return;
          }
          if (/^[A-Z].*Controller$/.test(property)) {
            controllerName = property.charAt(0).toLowerCase() + property.substr(1);
            store = stateManager.get("store");
            controller = stateManager.get(controllerName);
            if (!controller) {
              return;
            }
            return controller.set("store", store);
          }
        }
      });
    } else if (Application.initializer) {
      Application.initializer({
        name: "store",
        initialize: function(container, application) {
          application.register("store:main", application.Store);
          return container.lookup("store:main");
        }
      });
      return Application.initializer({
        name: "injectStore",
        initialize: function(container, application) {
          application.inject("controller", "store", "store:main");
          return application.inject("route", "store", "store:main");
        }
      });
    }
  });

}).call(this);
(function() {
  Emu.RestAdapter = Ember.Object.extend({
    init: function() {
      var _ref;

      return this._serializer = ((_ref = this.get("serializer")) != null ? _ref.create() : void 0) || Emu.Serializer.create();
    },
    findAll: function(type, store, collection) {
      var url,
        _this = this;

      url = collection.get("parent") ? this._getEndpointNestedSubCollection(collection) : this._getEndpointForModel(type);
      return $.ajax({
        url: url,
        type: "GET",
        success: function(jsonData) {
          return _this._didFindAll(store, collection, jsonData);
        }
      });
    },
    findById: function(type, store, model, id) {
      var _this = this;

      return $.ajax({
        url: this._getEndpointForModel(type) + "/" + id,
        type: "GET",
        success: function(jsonData) {
          return _this._didFindById(store, model, jsonData);
        },
        error: function() {
          return _this._didError(store, model);
        }
      });
    },
    findQuery: function(type, store, collection, queryHash) {
      var _this = this;

      return $.ajax({
        url: this._getEndpointForModel(type) + this._serializer.serializeQueryHash(queryHash),
        type: "GET",
        success: function(jsonData) {
          _this._serializer.deserializeCollection(collection, jsonData);
          return store.didFindQuery(collection);
        }
      });
    },
    insert: function(store, model) {
      return this._save(store, model, "POST");
    },
    update: function(store, model) {
      return this._save(store, model, "PUT");
    },
    _save: function(store, model, requestType) {
      var jsonData,
        _this = this;

      jsonData = this._serializer.serializeModel(model);
      return $.ajax({
        url: this._getEndpointForModel(model.constructor),
        data: jsonData,
        type: requestType,
        success: function(jsonData) {
          return _this._didSave(store, model, jsonData);
        }
      });
    },
    _didFindAll: function(store, collection, jsonData) {
      this._serializer.deserializeCollection(collection, jsonData);
      return store.didFindAll(collection);
    },
    _didFindById: function(store, model, jsonData) {
      this._serializer.deserializeModel(model, jsonData);
      return store.didFindById(model);
    },
    _didError: function(store, model) {
      return store.didError(model);
    },
    _didSave: function(store, model, jsonData) {
      this._serializer.deserializeModel(model, jsonData);
      return store.didSave(model);
    },
    _getEndpointNestedSubCollection: function(collection) {
      return this._getBaseUrl() + this._serializer.serializeTypeName(collection.get("parent").constructor) + "/" + collection.get("parent.id") + "/" + this._serializer.serializeTypeName(collection.get("type"));
    },
    _getEndpointForModel: function(type) {
      return this._getBaseUrl() + this._serializer.serializeTypeName(type);
    },
    _getBaseUrl: function() {
      if (this.get("namespace")) {
        return this.get("namespace") + "/";
      } else {
        return "";
      }
    }
  });

}).call(this);
(function() {
  Emu.field = function(type, options) {
    var meta;

    if (options == null) {
      options = {};
    }
    meta = {
      type: function() {
        return Ember.get(type) || type;
      },
      options: options,
      isField: true,
      isModel: function() {
        var _ref;

        return (_ref = Ember.get(type)) != null ? _ref.isEmuModel : void 0;
      }
    };
    return Ember.computed(function(key, value, oldValue) {
      var _ref, _ref1;

      meta = this.constructor.metaForProperty(key);
      if (arguments.length > 1) {
        Emu.Model.setAttr(this, key, value);
        this.set("isDirty", true);
      } else {
        if (meta.options.lazy) {
          if ((_ref = this.get("store")) != null) {
            _ref.loadAll(Emu.Model.getAttr(this, key));
          }
        } else if (meta.options.partial) {
          if ((_ref1 = this.get("store")) != null) {
            _ref1.loadModel(this);
          }
        } else if (meta.options.defaultValue && !Emu.Model.getAttr(this, key)) {
          Emu.Model.setAttr(this, key, meta.options.defaultValue);
        }
      }
      return Emu.Model.getAttr(this, key);
    }).property().meta(meta);
  };

}).call(this);
(function() {
  Emu.Model = Ember.Object.extend({
    init: function() {
      if (!this.get("store")) {
        return this.set("store", Ember.get(Emu, "defaultStore"));
      }
    },
    save: function() {
      return this.get("store").save(this);
    }
  });

  Emu.proxyToStore = function(methodName) {
    return function() {
      var args, store;

      store = Ember.get(Emu, "defaultStore");
      args = [].slice.call(arguments);
      args.unshift(this);
      Ember.assert("Cannot call " + methodName + ". You need define a store first like this: App.Store = Emu.Store.extend()", !!store);
      return store[methodName].apply(store, args);
    };
  };

  Emu.Model.reopenClass({
    isEmuModel: true,
    createRecord: Emu.proxyToStore("createRecord"),
    find: Emu.proxyToStore("find"),
    eachEmuField: function(callback) {
      return this.eachComputedProperty(function(property, meta) {
        if (meta.isField) {
          return callback(property, meta);
        }
      });
    },
    getAttr: function(record, key) {
      var meta, _ref;

      meta = record.constructor.metaForProperty(key);
      if ((_ref = record._attributes) == null) {
        record._attributes = {};
      }
      if (meta.options.collection && !record._attributes[key]) {
        record._attributes[key] = Emu.ModelCollection.create({
          parent: record,
          type: meta.type()
        });
        record._attributes[key].addObserver("content.@each", function() {
          return record.set("isDirty", true);
        });
      }
      return record._attributes[key];
    },
    setAttr: function(record, key, value) {
      var _ref;

      if ((_ref = record._attributes) == null) {
        record._attributes = {};
      }
      return record._attributes[key] = value;
    }
  });

}).call(this);
(function() {
  Emu.ModelCollection = Ember.ArrayProxy.extend({
    init: function() {
      this.set("content", Ember.A([]));
      this.createRecord = function(hash) {
        var model;

        model = this.get("type").create(hash);
        model.set("store", this.get("store"));
        return this.pushObject(model);
      };
      return this.find = function(predicate) {
        return this.get("content").find(predicate);
      };
    }
  });

}).call(this);
(function() {
  Emu.AttributeSerializers = {
    string: {
      serialize: function(value) {
        if (Ember.isEmpty(value)) {
          return null;
        } else {
          return value;
        }
      },
      deserialize: function(value) {
        if (Ember.isEmpty(value)) {
          return null;
        } else {
          return value;
        }
      }
    },
    array: {
      serialize: function(value) {
        if (Em.typeOf(value) === 'array') {
          return value;
        } else {
          return null;
        }
      },
      deserialize: function(value) {
        switch (Em.typeOf(value)) {
          case "array":
            return value;
          case "string":
            return value.split(',').map(function(item) {
              return jQuery.trim(item);
            });
          default:
            return null;
        }
      }
    }
  };

}).call(this);
(function() {
  Emu.Serializer = Ember.Object.extend({
    serializeKey: function(key) {
      return key[0].toLowerCase() + key.slice(1);
    },
    deserializeKey: function(key) {
      return key;
    },
    serializeTypeName: function(type) {
      var parts;

      parts = type.toString().split(".");
      return this.serializeKey(parts[parts.length - 1]);
    },
    serializeModel: function(model) {
      var jsonData,
        _this = this;

      jsonData = {
        id: model.get("id")
      };
      model.constructor.eachEmuField(function(property, meta) {
        return _this._serializeProperty(model, jsonData, property, meta);
      });
      return jsonData;
    },
    deserializeModel: function(model, jsonData) {
      var _this = this;

      if (jsonData.id) {
        model.set("id", jsonData.id);
      }
      model.constructor.eachEmuField(function(property, meta) {
        var serializedProperty;

        serializedProperty = _this.serializeKey(property);
        return _this._deserializeProperty(model, property, jsonData[serializedProperty], meta);
      });
      return model;
    },
    deserializeCollection: function(collection, jsonData) {
      var oldModels,
        _this = this;

      oldModels = collection.toArray();
      collection.clear();
      return jsonData.forEach(function(item) {
        var existingModel, model;

        existingModel = oldModels.find(function(x) {
          return x.get("id") === item.id;
        });
        model = existingModel ? collection.pushObject(existingModel) : collection.createRecord();
        return _this.deserializeModel(model, item);
      });
    },
    serializeQueryHash: function(queryHash) {
      var key, queryString, value;

      queryString = "?";
      for (key in queryHash) {
        value = queryHash[key];
        queryString += this.serializeKey(key) + "=" + value + "&";
      }
      return queryString.slice(0, queryString.length - 1);
    },
    _deserializeProperty: function(model, property, value, meta) {
      var attributeSerializer, modelProperty;

      if (meta.options.collection) {
        if (value) {
          return this.deserializeCollection(Emu.Model.getAttr(model, property), value);
        }
      } else if (meta.isModel()) {
        if (value) {
          modelProperty = meta.type().create();
          this.deserializeModel(modelProperty, value);
          return model.set(property, modelProperty);
        }
      } else {
        attributeSerializer = Emu.AttributeSerializers[meta.type()];
        value = attributeSerializer.deserialize(value);
        if (value) {
          return model.set(property, value);
        }
      }
    },
    _serializeProperty: function(model, jsonData, property, meta) {
      var attributeSerializer, collection, propertyValue, serializedKey,
        _this = this;

      serializedKey = this.serializeKey(property);
      if (meta.options.collection) {
        if (collection = Emu.Model.getAttr(model, property)) {
          return jsonData[serializedKey] = collection.get("length") > 0 ? collection.map(function(item) {
            return _this.serializeModel(item);
          }) : void 0;
        }
      } else if (meta.isModel()) {
        propertyValue = Emu.Model.getAttr(model, property);
        if (propertyValue) {
          return jsonData[serializedKey] = this.serializeModel(propertyValue);
        }
      } else {
        attributeSerializer = Emu.AttributeSerializers[meta.type()];
        return jsonData[serializedKey] = attributeSerializer.serialize(Emu.Model.getAttr(model, property));
      }
    }
  });

}).call(this);
(function() {
  Emu.UnderscoreSerializer = Emu.Serializer.extend({
    serializeKey: function(key) {
      return this._super(key).replace(/([A-Z])/g, function(x) {
        return "_" + x.toLowerCase();
      });
    },
    deserializeKey: function(key) {
      return key.replace(/(\_[a-z])/g, function(x) {
        return x.toUpperCase().replace('_', '');
      });
    }
  });

}).call(this);
(function() {
  Emu.Store = Ember.Object.extend({
    init: function() {
      var _ref;

      if (!Ember.get(Emu, "defaultStore")) {
        Ember.set(Emu, "defaultStore", this);
      }
      if (!this.get("modelCollections")) {
        this.set("modelCollections", {});
      }
      if (!this.get("queryCollections")) {
        this.set("queryCollections", {});
      }
      if (!this.get("deferredQueries")) {
        this.set("deferredQueries", {});
      }
      return this._adapter = ((_ref = this.get("adapter")) != null ? _ref.create() : void 0) || Emu.RestAdapter.create();
    },
    createRecord: function(type) {
      var collection;

      collection = this._getCollectionForType(type);
      return collection.createRecord({
        isDirty: true
      });
    },
    find: function(type, param) {
      if (!param) {
        return this.findAll(type);
      }
      switch (Em.typeOf(param)) {
        case 'string':
        case 'number':
          return this.findById(type, param);
        case 'object':
          return this.findQuery(type, param);
        case 'function':
          return this.findPredicate(type, param);
      }
    },
    findAll: function(type) {
      var collection;

      collection = this._getCollectionForType(type);
      this.loadAll(collection);
      return collection;
    },
    didFindAll: function(collection) {
      var deferredQueries;

      this._didCollectionLoad(collection);
      deferredQueries = this.get("deferredQueries")[collection.type];
      if (deferredQueries) {
        return deferredQueries.forEach(function(deferredQuery) {
          var queryResult;

          queryResult = collection.filter(deferredQuery.predicate);
          return queryResult.forEach(function(item) {
            return deferredQuery.results.pushObject(item);
          });
        });
      }
    },
    findById: function(type, id) {
      var collection, model;

      collection = this._getCollectionForType(type);
      model = collection.find(function(item) {
        return item.get("id") === id;
      });
      if (!model) {
        model = collection.createRecord({
          id: id
        });
      }
      return this.loadModel(model);
    },
    didFindById: function(model) {
      model.set("isLoading", false);
      model.set("isLoaded", true);
      return model.set("isDirty", false);
    },
    didError: function(model) {
      model.set('isError', true);
      return model.set('isLoading', false);
    },
    findQuery: function(type, queryHash) {
      var collection;

      collection = this._getCollectionForQuery(type, queryHash);
      if (!collection.get("isLoading")) {
        collection.set("isLoading", true);
        this._adapter.findQuery(type, this, collection, queryHash);
      }
      return collection;
    },
    didFindQuery: function(collection) {
      return this._didCollectionLoad(collection);
    },
    findPredicate: function(type, predicate) {
      var allModels, queries, results;

      allModels = this.findAll(type);
      results = Emu.ModelCollection.create({
        type: type,
        store: this
      });
      if (allModels.get("isLoaded")) {
        allModels.forEach(function(model) {
          if (predicate(model)) {
            return results.pushObject(model);
          }
        });
      } else {
        queries = this.get("deferredQueries")[type] || (this.get("deferredQueries")[type] = []);
        queries.pushObject({
          predicate: predicate,
          results: results
        });
      }
      return results;
    },
    save: function(model) {
      if (model.get("id")) {
        return this._adapter.update(this, model);
      } else {
        return this._adapter.insert(this, model);
      }
    },
    didSave: function(model) {
      model.set("isDirty", false);
      model.set("isLoaded", true);
      return model.set("isLoading", false);
    },
    loadAll: function(collection) {
      if (collection.get("isLoading") || collection.get("isLoaded")) {
        return collection;
      }
      collection.set("isLoading", true);
      this._adapter.findAll(collection.get("type"), this, collection);
      return collection;
    },
    loadModel: function(model) {
      if (!model.get("isLoading") && !model.get("isLoaded")) {
        model.set("isLoading", true);
        this._adapter.findById(model.constructor, this, model, model.get("id"));
      }
      return model;
    },
    _didCollectionLoad: function(collection) {
      collection.set("isLoaded", true);
      return collection.set("isLoading", false);
    },
    _getCollectionForType: function(type) {
      return this.get("modelCollections")[type] || (this.get("modelCollections")[type] = Emu.ModelCollection.create({
        type: type,
        store: this
      }));
    },
    _getCollectionForQuery: function(type, queryHash) {
      var key, queries;

      key = JSON.stringify(queryHash);
      queries = this.get("queryCollections")[type] || (this.get("queryCollections")[type] = {});
      return this.get("queryCollections")[type][key] || (this.get("queryCollections")[type][key] = Emu.ModelCollection.create({
        type: type,
        store: this
      }));
    }
  });

}).call(this);

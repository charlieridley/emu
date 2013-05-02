// Version: 0.1.0-71-g35a08f4
// Last commit: 35a08f4 (2013-05-01 23:16:20 -0400)


(function() {
  window.Emu = Ember.Namespace.create({
    VERSION: "0.1.0"
  });

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
  Emu.PushDataAdapter = Ember.Object.extend({
    init: function() {
      var _ref;

      return this._serializer = ((_ref = this.get("serializer")) != null ? _ref.create() : void 0) || Emu.Serializer.create();
    },
    start: function(store) {
      var _ref,
        _this = this;

      return (_ref = this.updatableTypes) != null ? _ref.forEach(function(type) {
        return _this.listenForUpdates(store, Ember.get(type));
      }) : void 0;
    },
    listenForUpdates: function(store, type) {
      return typeof this.registerForUpdates === "function" ? this.registerForUpdates(store, type) : void 0;
    },
    didUpdate: function(type, store, json) {
      var model, primaryKey;

      primaryKey = Emu.Model.primaryKey(type);
      model = store.findUpdatable(type, json[primaryKey]);
      if (model) {
        return this._serializer.deserializeModel(model, json, true);
      }
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
      var _this = this;

      return $.ajax({
        url: this._getUrlForModel(collection),
        type: "GET",
        success: function(jsonData) {
          return _this._didFindAll(store, collection, jsonData);
        },
        error: function() {
          return _this._didError(store, collection);
        }
      });
    },
    findById: function(type, store, model, id) {
      var _this = this;

      return $.ajax({
        url: this._getUrlForModel(model) + "/" + id,
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
        url: this._getUrlForType(type) + this._serializer.serializeQueryHash(queryHash),
        type: "GET",
        success: function(jsonData) {
          _this._serializer.deserializeCollection(collection, jsonData);
          return store.didFindQuery(collection);
        },
        error: function() {
          return _this._didError(store, collection);
        }
      });
    },
    findPage: function(pagedCollection, store, pageNumber) {
      var _this = this;

      return $.ajax({
        url: this._getUrlForModel(pagedCollection) + this._serializer.serializeQueryHash({
          pageNumber: pageNumber,
          pageSize: pagedCollection.get("pageSize")
        }),
        type: "GET",
        success: function(jsonData) {
          return _this._didFindPage(store, pagedCollection, jsonData, pageNumber);
        }
      });
    },
    insert: function(store, model) {
      return this._save(store, model, "POST");
    },
    update: function(store, model) {
      return this._save(store, model, "PUT", model.primaryKeyValue());
    },
    "delete": function(store, model) {
      var _this = this;

      return $.ajax({
        url: this._getUrlForModel(model) + "/" + model.primaryKeyValue(),
        type: "DELETE",
        success: function() {
          return store.didDeleteRecord(model);
        },
        error: function() {
          return _this._didError(store, model);
        }
      });
    },
    _save: function(store, model, requestType, id) {
      var jsonData,
        _this = this;

      jsonData = this._serializer.serializeModel(model);
      return $.ajax({
        url: this._getUrlForModel(model) + (id ? "/" + id : ""),
        data: jsonData,
        type: requestType,
        success: function(jsonData) {
          return _this._didSave(store, model, jsonData);
        },
        error: function() {
          return _this._didError(store, model);
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
    _didFindPage: function(store, pagedCollection, jsonData, pageNumber) {
      var results, resultsKey, totalRecordCount, totalRecordCountKey;

      totalRecordCountKey = this._serializer.serializeKey("totalRecordCount");
      resultsKey = this._serializer.serializeKey("results");
      totalRecordCount = jsonData[totalRecordCountKey];
      results = jsonData[resultsKey];
      pagedCollection.set("totalRecordCount", totalRecordCount);
      this._serializer.deserializeCollection(pagedCollection, results, true);
      return store.didFindPage(pagedCollection, pageNumber);
    },
    _didError: function(store, model) {
      return store.didError(model);
    },
    _didSave: function(store, model, jsonData) {
      this._serializer.deserializeModel(model, jsonData);
      return store.didSave(model);
    },
    _getUrlForModel: function(model) {
      var buildUrl, currentModel, url,
        _this = this;

      url = Emu.isCollection(model) ? this._serializer.serializeTypeName(model.get("type")) : "";
      currentModel = model;
      buildUrl = function() {
        currentModel = currentModel.get("parent");
        if (Emu.isCollection(currentModel)) {
          return url = _this._serializer.serializeTypeName(currentModel.get("type")) + (url ? "/" + url : "");
        } else {
          return url = currentModel.primaryKeyValue() + "/" + url;
        }
      };
      while (currentModel.get("parent")) {
        buildUrl();
      }
      return this._getBaseUrl() + url;
    },
    _getUrlForType: function(type) {
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
  Emu.ModelEvented = Ember.Mixin.create({
    didStartLoading: function() {
      return this.trigger("didStartLoading");
    },
    didFinishLoading: function() {
      return this.trigger("didFinishLoading");
    },
    didStartSaving: function() {
      return this.trigger("didStartSaving");
    },
    didFinishSaving: function() {
      return this.trigger("didFinishSaving");
    },
    didStateChange: function() {
      return this.trigger("didStateChange");
    },
    didError: function() {
      return this.trigger("didError");
    }
  });

}).call(this);
(function() {
  Emu.StateTracked = Ember.Mixin.create({
    init: function() {
      return Emu.StateTracker.create().track(this);
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
        this.didStateChange();
        this.set("hasValue", true);
      } else {
        if (meta.options.lazy && this.primaryKeyValue()) {
          if ((_ref = this.get("store")) != null) {
            _ref.loadAll(Emu.Model.getAttr(this, key));
          }
        } else if (meta.options.partial) {
          if ((_ref1 = this.get("store")) != null) {
            _ref1.loadModel(this);
          }
        }
        if (meta.options.paged) {
          Emu.Model.getAttr(this, key).loadMore();
        }
        if (meta.options.defaultValue && !Emu.Model.getAttr(this, key)) {
          Emu.Model.setAttr(this, key, meta.options.defaultValue);
        }
      }
      return Emu.Model.getAttr(this, key);
    }).property().meta(meta);
  };

}).call(this);
(function() {
  Emu.Model = Ember.Object.extend(Emu.ModelEvented, Emu.StateTracked, Ember.Evented, {
    init: function() {
      this._super();
      if (!this.get("store")) {
        this.set("store", Ember.get(Emu, "defaultStore"));
      }
      this._primaryKey = Emu.Model.primaryKey(this.constructor);
      if (this.get("isDirty") === void 0) {
        this.set("isDirty", true);
      }
      return Emu.StateTracker.create().track(this);
    },
    save: function() {
      return this.get("store").save(this);
    },
    subscribeToUpdates: function() {
      return this.get("store").subscribeToUpdates(this);
    },
    primaryKey: function() {
      return this._primaryKey || (this._primaryKey = Emu.Model.primaryKey(this.constructor));
    },
    primaryKeyValue: function(value) {
      if (value) {
        this.set(this.primaryKey(), value);
        this.set("hasValue", true);
      }
      return this.get(this.primaryKey());
    },
    clear: function() {
      var _this = this;

      this.constructor.eachEmuField(function(property, meta) {
        if (meta.isModel() || meta.options.collection) {
          return Emu.Model.getAttr(_this, property).clear();
        } else {
          return _this.set(property, void 0);
        }
      });
      return this.set("hasValue", false);
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
    findPaged: Emu.proxyToStore("findPaged"),
    primaryKey: function(type) {
      var primaryKey, primaryKeyCount,
        _this = this;

      if (type == null) {
        type = this;
      }
      primaryKey = "id";
      primaryKeyCount = 0;
      type.eachComputedProperty(function(property, meta) {
        var _ref;

        if ((_ref = meta.options) != null ? _ref.primaryKey : void 0) {
          primaryKey = property;
          return primaryKeyCount++;
        }
      });
      if (primaryKeyCount > 1) {
        throw new Error("Error with " + this + ": You can only mark one field as a primary key");
      }
      return primaryKey;
    },
    eachEmuField: function(callback) {
      return this.eachComputedProperty(function(property, meta) {
        if (meta.isField) {
          return callback(property, meta);
        }
      });
    },
    getAttr: function(record, key) {
      var collectionType, meta, _ref;

      meta = record.constructor.metaForProperty(key);
      if ((_ref = record._attributes) == null) {
        record._attributes = {};
      }
      if (!record._attributes[key]) {
        if (meta.options.collection) {
          collectionType = meta.options.paged ? Emu.PagedModelCollection : Emu.ModelCollection;
          record._attributes[key] = collectionType.create({
            parent: record,
            type: meta.type(),
            store: record.get("store"),
            lazy: meta.options.lazy
          });
          record._attributes[key].addObserver("hasValue", function() {
            return record.set("hasValue", true);
          });
          if (!meta.options.lazy) {
            record._attributes[key].on("didStateChange", function() {
              return record.didStateChange();
            });
          }
          if (meta.options.updatable) {
            record._attributes[key].subscribeToUpdates();
          }
        } else if (meta.isModel()) {
          record._attributes[key] = meta.type().create();
          record._attributes[key].on("didStateChange", function() {
            return record.didStateChange();
          });
        }
      }
      return record._attributes[key];
    },
    setAttr: function(record, key, value) {
      var _ref;

      if ((_ref = record._attributes) == null) {
        record._attributes = {};
      }
      record._attributes[key] = value;
      return record.set("hasValue", true);
    }
  });

}).call(this);
(function() {
  Emu.ModelCollection = Ember.ArrayProxy.extend(Emu.ModelEvented, Emu.StateTracked, Ember.Evented, {
    init: function() {
      var _this = this;

      this._super();
      if (!this.get("content")) {
        this.set("content", Ember.A([]));
      }
      this.createRecord = function(hash) {
        var model, paramHash, primaryKey;

        primaryKey = Emu.Model.primaryKey(this.get("type"));
        paramHash = {
          store: this.get("store")
        };
        paramHash[primaryKey] = hash != null ? hash.id : void 0;
        model = this.get("type").create(paramHash);
        model.set("parent", this);
        model.setProperties(hash);
        if (this._subscribeToUpdates) {
          model.subscribeToUpdates();
        }
        return this.pushObject(model);
      };
      this.pushObject = function(model) {
        model.on("didStateChange", function() {
          return _this.didStateChange();
        });
        return _this.get("content").pushObject(model);
      };
      this.addObserver("content.@each.isDirty", function() {
        _this.didStateChange();
        return _this.set("hasValue", true);
      });
      return this.find = function(predicate) {
        return this.get("content").find(predicate);
      };
    },
    subscribeToUpdates: function() {
      return this._subscribeToUpdates = true;
    },
    deleteRecord: function(model) {
      return this.removeObject(model);
    },
    length: (function() {
      return this.get("content.length");
    }).property("content.length").volatile(),
    clear: function() {
      this._super();
      return this.set("hasValue", false);
    }
  });

}).call(this);
(function() {
  Emu.PagedModelCollection = Emu.ModelCollection.extend({
    pageSize: 250,
    loadedPageCursor: 1,
    init: function() {
      this._super();
      return this.set("pages", Em.A([]));
    },
    loadMore: function() {
      this.get("store").loadPaged(this, this.get("loadedPageCursor"));
      return this._incrementCursor("loadedPageCursor");
    },
    _incrementCursor: function(cursor) {
      return this.set(cursor, this.get(cursor) + 1);
    }
  });

}).call(this);
(function() {
  Emu.StateTracker = Ember.Object.extend({
    track: function(model) {
      model.on("didStartLoading", function() {
        model.set("isLoading", true);
        return model.set("isLoaded", false);
      });
      model.on("didFinishLoading", function() {
        model.set("isLoading", false);
        model.set("isLoaded", true);
        return model.set("isDirty", false);
      });
      model.on("didStartSaving", function() {
        return model.set("isSaving", true);
      });
      model.on("didFinishSaving", function() {
        model.set("isSaving", false);
        model.set("isDirty", false);
        return model.set("isLoaded", true);
      });
      model.on("didStateChange", function() {
        return model.set("isDirty", true);
      });
      return model.on("didError", function() {
        model.set("isDirty", true);
        model.set("isLoaded", false);
        model.set("isLoading", false);
        model.set("isSaving", false);
        return model.set("isError", true);
      });
    }
  });

}).call(this);
(function() {
  Emu.AttributeSerializers = {
    string: {
      serialize: function(value) {
        if (Ember.isNone(value)) {
          return null;
        } else {
          return String(value);
        }
      },
      deserialize: function(value) {
        if (Ember.isEmpty(value)) {
          return null;
        } else {
          return String(value);
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
    },
    boolean: {
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
    number: {
      serialize: function(value) {
        if (Ember.isNone(value)) {
          return null;
        } else {
          return Number(value);
        }
      },
      deserialize: function(value) {
        if (Ember.isEmpty(value)) {
          return null;
        } else {
          return Number(value);
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

      jsonData = {};
      jsonData[model.primaryKey()] = model.primaryKeyValue();
      model.constructor.eachEmuField(function(property, meta) {
        return _this._serializeProperty(model, jsonData, property, meta);
      });
      return jsonData;
    },
    deserializeModel: function(model, jsonData, addative) {
      var primaryKeyValue,
        _this = this;

      primaryKeyValue = jsonData[model.primaryKey()];
      if (primaryKeyValue) {
        model.primaryKeyValue(primaryKeyValue);
      }
      model.constructor.eachEmuField(function(property, meta) {
        var serializedProperty;

        serializedProperty = _this.serializeKey(property);
        return _this._deserializeProperty(model, property, jsonData[serializedProperty], meta, addative);
      });
      return model;
    },
    deserializeCollection: function(collection, jsonData, addative) {
      var existingItems, ids, missingItems,
        _this = this;

      existingItems = collection.toArray();
      collection.clear();
      if (addative) {
        ids = jsonData.map(function(item) {
          return item[collection.get("type").primaryKey()];
        });
        missingItems = existingItems.filter(function(item) {
          return !ids.contains(item.primaryKeyValue());
        });
        collection.pushObjects(missingItems);
      }
      return jsonData.forEach(function(item) {
        var existingModel, model;

        existingModel = existingItems.find(function(x) {
          return x.primaryKeyValue() === item[x.primaryKey()];
        });
        model = existingModel ? collection.pushObject(existingModel) : collection.createRecord();
        return _this.deserializeModel(model, item, addative);
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
    _deserializeProperty: function(model, property, value, meta, addative) {
      var attributeSerializer, modelProperty;

      if (meta.options.collection) {
        if (value) {
          return this.deserializeCollection(Emu.Model.getAttr(model, property), value, addative);
        }
      } else if (meta.isModel()) {
        modelProperty = Emu.Model.getAttr(model, property);
        if (!addative) {
          modelProperty.clear();
        }
        if (value) {
          return this.deserializeModel(modelProperty, value, addative);
        }
      } else {
        attributeSerializer = Emu.AttributeSerializers[meta.type()];
        value = attributeSerializer.deserialize(value);
        if (value != null) {
          return model.set(property, value);
        }
      }
    },
    _serializeProperty: function(model, jsonData, property, meta) {
      var attributeSerializer, serializedKey, value,
        _this = this;

      value = Emu.Model.getAttr(model, property);
      serializedKey = this.serializeKey(property);
      if (meta.options.collection) {
        if (!meta.options.lazy) {
          return jsonData[serializedKey] = (value != null ? value.get("hasValue") : void 0) ? value.map(function(item) {
            return _this.serializeModel(item);
          }) : void 0;
        }
      } else if (meta.isModel()) {
        if (value.get("hasValue")) {
          return jsonData[serializedKey] = this.serializeModel(value);
        }
      } else {
        if (value) {
          attributeSerializer = Emu.AttributeSerializers[meta.type()];
          return jsonData[serializedKey] = attributeSerializer.serialize(value);
        }
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
    },
    serializeTypeName: function(type) {
      var name, parts, typeString;

      if (type.resourceName) {
        name = type.resourceName;
        if (typeof name === 'function') {
          return name();
        } else {
          return name;
        }
      } else {
        typeString = type.toString();
        parts = typeString.split('.');
        name = parts[parts.length - 1];
        return name.replace(/([A-Z])/g, '_$1').toLowerCase().slice(1) + 's';
      }
    }
  });

}).call(this);
(function() {
  Emu.Store = Ember.Object.extend({
    init: function() {
      var _ref, _ref1, _ref2;

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
      if (!this.get("updatableModels")) {
        this.set("updatableModels", {});
      }
      this._adapter = ((_ref = this.get("adapter")) != null ? _ref.create() : void 0) || Emu.RestAdapter.create();
      this._pushAdapter = (_ref1 = this.get("pushAdapter")) != null ? _ref1.create() : void 0;
      return (_ref2 = this._pushAdapter) != null ? _ref2.start(this) : void 0;
    },
    createRecord: function(type, hash) {
      var collection;

      collection = this._getCollectionForType(type);
      return collection.createRecord(hash);
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
          deferredQuery.results.pushObjects(queryResult);
          return deferredQuery.results.didFinishLoading();
        });
      }
    },
    findById: function(type, id) {
      var collection, model;

      collection = this._getCollectionForType(type);
      model = collection.find(function(item) {
        return item.primaryKeyValue() === id;
      });
      if (!model) {
        model = collection.createRecord({
          id: id
        });
        model.primaryKeyValue(id);
      }
      return this.loadModel(model);
    },
    findPaged: function(type, pageSize) {
      var pagedCollection;

      if (pageSize == null) {
        pageSize = 500;
      }
      pagedCollection = Emu.PagedModelCollection.create({
        type: type,
        pageSize: pageSize,
        store: this
      });
      pagedCollection.loadMore();
      return pagedCollection;
    },
    didFindById: function(model) {
      return model.didFinishLoading();
    },
    didError: function(model) {
      return model.didError();
    },
    findQuery: function(type, queryHash) {
      var collection;

      collection = this._getCollectionForQuery(type, queryHash);
      if (!collection.get("isLoading")) {
        collection.didStartLoading();
        this._adapter.findQuery(type, this, collection, queryHash);
      }
      return collection;
    },
    didFindQuery: function(collection) {
      return this._didCollectionLoad(collection);
    },
    findPredicate: function(type, predicate) {
      var allModels, filtered, queries, results;

      allModels = this.findAll(type);
      results = Emu.ModelCollection.create({
        type: type,
        store: this
      });
      if (allModels.get("isLoaded")) {
        filtered = allModels.filter(function(m) {
          return predicate(m);
        });
        results.pushObjects(filtered);
        results.didFinishLoading();
      } else {
        results.didStartLoading();
        queries = this.get("deferredQueries")[type] || (this.get("deferredQueries")[type] = []);
        queries.pushObject({
          predicate: predicate,
          results: results
        });
      }
      return results;
    },
    save: function(model) {
      model.didStartSaving();
      if (model.primaryKeyValue()) {
        return this._adapter.update(this, model);
      } else {
        return this._adapter.insert(this, model);
      }
    },
    didSave: function(model) {
      return model.didFinishSaving();
    },
    loadAll: function(collection) {
      if (collection.get("isLoading") || collection.get("isLoaded")) {
        return collection;
      }
      collection.didStartLoading();
      this._adapter.findAll(collection.get("type"), this, collection);
      return collection;
    },
    loadModel: function(model) {
      if (!model.get("isLoading") && !model.get("isLoaded")) {
        model.didStartLoading();
        this._adapter.findById(model.constructor, this, model, model.primaryKeyValue());
      }
      return model;
    },
    subscribeToUpdates: function(model) {
      var _base, _name, _ref;

      if (!this._pushAdapter) {
        throw new Error("You need to register a Emu.PushDataAdapter on your store: Emu.Store.create({pushAdapter: App.MyPushAdapter.create()});");
      }
      if (!this.findUpdatable(model.constructor, model.primaryKeyValue())) {
        if ((_ref = (_base = this.get("updatableModels"))[_name = model.constructor]) == null) {
          _base[_name] = [];
        }
        return this.get("updatableModels")[model.constructor].pushObject(model);
      }
    },
    findUpdatable: function(type, id) {
      var _ref;

      return (_ref = this.get("updatableModels")[type]) != null ? _ref.find(function(model) {
        return model.primaryKeyValue() === id;
      }) : void 0;
    },
    deleteRecord: function(model) {
      if (model.primaryKeyValue()) {
        return this._adapter["delete"](this, model);
      } else {
        return this.didDeleteRecord(model);
      }
    },
    didDeleteRecord: function(model) {
      return this._getCollectionForType(model.constructor).deleteRecord(model);
    },
    loadPaged: function(pagedCollection, pageNumber) {
      return this._adapter.findPage(pagedCollection, this, pageNumber);
    },
    didFindPage: function(pagedCollection, pageNumber) {},
    _didCollectionLoad: function(collection) {
      return collection.didFinishLoading();
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
(function() {
  var _this = this;

  Emu.isCollection = function(value) {
    return value.constructor === Emu.ModelCollection || value.constructor === Emu.PagedModelCollection;
  };

}).call(this);

(function() {
  Emu.SignalrPushDataAdapter = Emu.PushDataAdapter.extend({
    registerForUpdates: function(store, type) {
      var hub, modelKey, _ref,
        _this = this;

      modelKey = this._serializer.serializeTypeName(type);
      if (hub = (_ref = $.connection) != null ? _ref[modelKey + "Hub"] : void 0) {
        return hub.updated = function(json) {
          return _this.didUpdate(type, store, json);
        };
      }
    },
    start: function() {
      return $.connection.start();
    }
  });

}).call(this);

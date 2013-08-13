// Version: 0.1.0-89-gd8b5fbc
// Last commit: d8b5fbc (2013-08-12 22:32:25 -0400)


(function() {
  Emu.SignalrPushDataAdapter = Emu.PushDataAdapter.extend({
    registerForUpdates: function(store, type) {
      var hub, modelKey, _base, _ref, _ref1,
        _this = this;

      modelKey = this._serializer.serializeTypeName(type);
      if (hub = (_ref = $.connection) != null ? _ref[modelKey + "Hub"] : void 0) {
        return (_ref1 = (_base = hub.client).updated) != null ? _ref1 : _base.updated = function(json) {
          return _this.didUpdate(type, store, json);
        };
      }
    },
    start: function(store) {
      this._super(store);
      $.connection.hub.logging = true;
      return $.connection.hub.start().done(function() {
        return console.debug("Connected to SignalR hub");
      }).fail(function() {
        return console.debug("Failed to connect to SignalR hub");
      });
    }
  });

}).call(this);

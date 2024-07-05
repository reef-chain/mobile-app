var __create = Object.create;
var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __getProtoOf = Object.getPrototypeOf;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __export = (target, all) => {
  for (var name in all)
    __defProp(target, name, { get: all[name], enumerable: true });
};
var __copyProps = (to, from, except, desc) => {
  if (from && typeof from === "object" || typeof from === "function") {
    for (let key of __getOwnPropNames(from))
      if (!__hasOwnProp.call(to, key) && key !== except)
        __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
  }
  return to;
};
var __toESM = (mod, isNodeMode, target) => (target = mod != null ? __create(__getProtoOf(mod)) : {}, __copyProps(
  // If the importer is in node compatibility mode or this is not an ESM
  // file that has been converted to a CommonJS file using a Babel-
  // compatible transform (i.e. "__esModule" has not been set), then set
  // "default" to the CommonJS "module.exports" for node compatibility.
  isNodeMode || !mod || !mod.__esModule ? __defProp(target, "default", { value: mod, enumerable: true }) : target,
  mod
));
var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);
var emitter_io_exports = {};
__export(emitter_io_exports, {
  Emitter: () => Emitter,
  EmitterEvents: () => EmitterEvents,
  EmitterMessage: () => EmitterMessage,
  connect: () => connect
});
module.exports = __toCommonJS(emitter_io_exports);
var import_mqtt = __toESM(require("mqtt"));
class Emitter {
  /**
   * Connects to the emitter service.
   */
  connect(request, handler) {
    request = request || {};
    if (request.secure == null) {
      if (typeof window !== "undefined" && window != null && window.location != null && window.location.protocol != null) {
        request.secure = window.location.protocol == "https:";
      } else {
        request.secure = false;
      }
    }
    var defaultConnectOptions = {
      host: "api.emitter.io",
      port: request.secure ? 443 : 8080,
      keepalive: 30,
      secure: false
    };
    for (var k in defaultConnectOptions) {
      request[k] = "undefined" === typeof request[k] ? defaultConnectOptions[k] : request[k];
    }
    request.host = request.host.replace(/.*?:\/\//g, "");
    var brokerUrl = `${request.secure ? "wss://" : "ws://"}${request.host}:${request.port}`;
    this._callbacks = { connect: [handler] };
    this._mqtt = import_mqtt.default.connect(brokerUrl, request);
    this._mqtt.on(
      "connect",
      () => this._tryInvoke("connect" /* connect */, this)
    );
    this._mqtt.on(
      "close",
      () => this._tryInvoke("disconnect" /* disconnect */, this)
    );
    this._mqtt.on(
      "offline",
      () => this._tryInvoke("offline" /* offline */, this)
    );
    this._mqtt.on(
      "error",
      (error) => this._tryInvoke("error" /* error */, error)
    );
    this._mqtt.on("message", (topic, msg, packet) => {
      var message = new EmitterMessage(packet);
      if (this._startsWith(message.channel, "emitter/keygen")) {
        this._tryInvoke("keygen" /* keygen */, message.asObject());
      } else if (this._startsWith(message.channel, "emitter/presence")) {
        this._tryInvoke("presence" /* presence */, message.asObject());
      } else if (this._startsWith(message.channel, "emitter/me")) {
        this._tryInvoke("me" /* me */, message.asObject());
      } else {
        this._tryInvoke("message" /* message */, message);
      }
    });
    return this;
  }
  /**
   * Disconnects the client.
   */
  disconnect() {
    this._mqtt.end();
    return this;
  }
  /**
   * Publishes a message to the currently opened endpoint.
   */
  publish(request) {
    if (typeof request.key !== "string")
      this._throwError(
        "emitter.publish: request object does not contain a 'key' string."
      );
    if (typeof request.channel !== "string")
      this._throwError(
        "emitter.publish: request object does not contain a 'channel' string."
      );
    if (typeof request.message !== "object" && typeof request.message !== "string")
      this._throwError(
        "emitter.publish: request object does not contain a 'message' object."
      );
    var options = new Array();
    if (request.me == null || request.me == true) {
      options.push({ key: "me", value: "1" });
    } else {
      options.push({ key: "me", value: "0" });
    }
    if (request.ttl) {
      options.push({ key: "ttl", value: request.ttl.toString() });
    }
    var topic = this._formatChannel(request.key, request.channel, options);
    this._mqtt.publish(topic, request.message);
    return this;
  }
  /**
   * Publishes a message througth a link.
   */
  publishWithLink(request) {
    if (typeof request.link !== "string")
      this._throwError(
        "emitter.publishWithLink: request object does not contain a 'link' string."
      );
    if (typeof request.message !== "object" && typeof request.message !== "string")
      this._throwError(
        "emitter.publishWithLink: request object does not contain a 'message' object."
      );
    this._mqtt.publish(request.link, request.message);
    return this;
  }
  /**
   * Subscribes to a particular channel.
   */
  subscribe(request) {
    if (typeof request.key !== "string")
      this._throwError(
        "emitter.subscribe: request object does not contain a 'key' string."
      );
    if (typeof request.channel !== "string")
      this._throwError(
        "emitter.subscribe: request object does not contain a 'channel' string."
      );
    var options = new Array();
    if (request.last != null) {
      options.push({ key: "last", value: request.last.toString() });
    }
    var topic = this._formatChannel(request.key, request.channel, options);
    this._mqtt.subscribe(topic);
    return this;
  }
  /**
   * Create a link to a particular channel.
   */
  link(request) {
    if (typeof request.key !== "string")
      this._throwError(
        "emitter.link: request object does not contain a 'key' string."
      );
    if (typeof request.channel !== "string")
      this._throwError(
        "emitter.link: request object does not contain a 'channel' string."
      );
    if (typeof request.name !== "string")
      this._throwError(
        "emitter.link: request object does not contain a 'name' string."
      );
    if (typeof request.private !== "boolean")
      this._throwError(
        "emitter.link: request object does not contain 'private'."
      );
    if (typeof request.subscribe !== "boolean")
      this._throwError(
        "emitter.link: request object does not contain 'subscribe'."
      );
    var options = new Array();
    if (request.me == null || request.me == true) {
      options.push({ key: "me", value: "1" });
    } else {
      options.push({ key: "me", value: "0" });
    }
    if (request.ttl != null) {
      options.push({ key: "ttl", value: request.ttl.toString() });
    }
    var formattedChannel = this._formatChannel(null, request.channel, options);
    request = {
      key: request.key,
      channel: formattedChannel,
      name: request.name,
      private: request.private,
      subscribe: request.subscribe
    };
    this._mqtt.publish("emitter/link/", JSON.stringify(request));
    return this;
  }
  /**
   * Unsubscribes from a particular channel.
   */
  unsubscribe(request) {
    if (typeof request.key !== "string")
      this._throwError(
        "emitter.unsubscribe: request object does not contain a 'key' string."
      );
    if (typeof request.channel !== "string")
      this._throwError(
        "emitter.unsubscribe: request object does not contain a 'channel' string."
      );
    var topic = this._formatChannel(request.key, request.channel, []);
    this._mqtt.unsubscribe(topic);
    return this;
  }
  /**
   * Sends a key generation request to the server.
   */
  keygen(request) {
    if (typeof request.key !== "string")
      this._throwError(
        "emitter.keygen: request object does not contain a 'key' string."
      );
    if (typeof request.channel !== "string")
      this._throwError(
        "emitter.keygen: request object does not contain a 'channel' string."
      );
    this._mqtt.publish("emitter/keygen/", JSON.stringify(request));
    return this;
  }
  /**
   * Sends a presence request to the server.
   */
  presence(request) {
    if (typeof request.key !== "string")
      this._throwError(
        "emitter.presence: request object does not contain a 'key' string."
      );
    if (typeof request.channel !== "string")
      this._throwError(
        "emitter.presence: request object does not contain a 'channel' string."
      );
    this._mqtt.publish("emitter/presence/", JSON.stringify(request));
    return this;
  }
  /**
   * Request information about the connection to the server.
   */
  me() {
    this._mqtt.publish("emitter/me/", "");
    return this;
  }
  /**
   * Hooks an event to the client.
   */
  on(event, callback) {
    this._checkEvent("off", event);
    if (!this._callbacks) {
      this._throwError("emitter.on: called before connecting");
    }
    if (!this._callbacks[event]) {
      this._callbacks[event] = [];
    }
    if (this._callbacks[event].indexOf(callback) === -1) {
      this._callbacks[event].push(callback);
    }
    return this;
  }
  /**
   * Unhooks an event from the client.
   */
  off(event, callback) {
    this._checkEvent("off", event);
    if (!this._callbacks) {
      this._throwError("emitter.off: called before connecting");
    }
    var eventCallbacks = this._callbacks[event];
    if (eventCallbacks) {
      var index = eventCallbacks.indexOf(callback);
      if (index >= 0) {
        eventCallbacks.splice(index, 1);
      }
    }
    return this;
  }
  _checkEvent(method, event) {
    if (!EmitterEvents[event]) {
      var names = Object.keys(EmitterEvents);
      var values = names.map(
        (name, index) => `${index === names.length - 1 ? "or " : ""}'${name}'`
      ).join(", ");
      this._throwError(
        `emitter.${method}: unknown event type, supported values are ${values}.`
      );
    }
  }
  /**
   * Invokes the callback with a specific name.
   */
  _tryInvoke(name, args) {
    var callbacks = this._callbacks[name];
    if (callbacks) {
      callbacks.filter((callback) => callback).forEach((callback) => callback(args));
    }
  }
  /**
   * Formats a channel for emitter.io protocol.
   *
   * @private
   * @param {string} key The key to use.
   * @param {string} channel The channel name.
   * @param {...Option[]} options The list of options to apply.
   * @returns
   */
  _formatChannel(key, channel, options) {
    var formatted = channel;
    if (key && key.length > 0)
      formatted = this._endsWith(key, "/") ? key + channel : key + "/" + channel;
    if (!this._endsWith(formatted, "/"))
      formatted += "/";
    if (options != null && options.length > 0) {
      formatted += "?";
      for (var i = 0; i < options.length; ++i) {
        formatted += options[i].key + "=" + options[i].value;
        if (i + 1 < options.length)
          formatted += "&";
      }
    }
    return formatted;
  }
  /**
   * Checks if a string starts with a prefix.
   */
  _startsWith(text, prefix) {
    return text.slice(0, prefix.length) == prefix;
  }
  /**
   * Checks whether a string ends with a suffix.
   */
  _endsWith(text, suffix) {
    return text.indexOf(suffix, text.length - suffix.length) !== -1;
  }
  /**
   * Logs the error and throws it
   */
  _throwError(message) {
    console.error(message);
    throw new Error(message);
  }
}
class EmitterMessage {
  /**
   * Creates an instance of EmitterMessage.
   *
   * @param {*} m The message
   */
  constructor(m) {
    this.channel = m.topic;
    this.binary = m.payload;
  }
  /**
   * Returns the payload as string.
   */
  asString() {
    return this.binary.toString();
  }
  /**
   * Returns the payload as binary.
   */
  asBinary() {
    return this.binary;
  }
  /**
   * Returns the payload as JSON-deserialized object.
   */
  asObject() {
    var object = {};
    try {
      object = JSON.parse(this.asString());
    } catch (err) {
      console.error(err);
    }
    return object;
  }
}
var EmitterEvents = /* @__PURE__ */ ((EmitterEvents2) => {
  EmitterEvents2["connect"] = "connect";
  EmitterEvents2["disconnect"] = "disconnect";
  EmitterEvents2["message"] = "message";
  EmitterEvents2["offline"] = "offline";
  EmitterEvents2["error"] = "error";
  EmitterEvents2["keygen"] = "keygen";
  EmitterEvents2["presence"] = "presence";
  EmitterEvents2["me"] = "me";
  return EmitterEvents2;
})(EmitterEvents || {});
function connect(request, connectCallback) {
  var client = new Emitter();
  client.connect(request, connectCallback);
  return client;
}
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  Emitter,
  EmitterEvents,
  EmitterMessage,
  connect
});

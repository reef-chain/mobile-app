var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __export = (target, all) => {
  for (var name in all)
    __defProp(target, name, { get: all[name], enumerable: true });
};
var __copyProps = (to, from2, except, desc) => {
  if (from2 && typeof from2 === "object" || typeof from2 === "function") {
    for (let key of __getOwnPropNames(from2))
      if (!__hasOwnProp.call(to, key) && key !== except)
        __defProp(to, key, { get: () => from2[key], enumerable: !(desc = __getOwnPropDesc(from2, key)) || desc.enumerable });
  }
  return to;
};
var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);
var reefscanEvents_exports = {};
__export(reefscanEvents_exports, {
  disconnectEmitter: () => disconnectEmitter,
  emitterConfig: () => emitterConfig,
  getBlockDataEmitter: () => getBlockDataEmitter,
  getConnectedIndexerEmitter$: () => getConnectedIndexerEmitter$,
  getIndexerConnState$: () => getIndexerConnState$,
  getIndexerEmitterConn$: () => getIndexerEmitterConn$,
  getIndexerEventsNetworkChannel: () => getIndexerEventsNetworkChannel,
  setReefscanEventsConnConfig: () => setReefscanEventsConnConfig
});
module.exports = __toCommonJS(reefscanEvents_exports);
var import_rxjs = require("rxjs");
var import_operators = require("rxjs/operators");
var import_emitter_io = require("../utils/emitter-io");
let emitterConfig = {
  host: "events.reefscan.info",
  port: 443,
  secure: true
};
const EMITTER_READ_KEY = "UMuO3iJMyZIM5H9v1PW7uOZEYLoUeCpc";
const emitterChannelObsCache = /* @__PURE__ */ new Map();
const emitterConnObsCache = /* @__PURE__ */ new Map();
const setReefscanEventsConnConfig = (config) => {
  emitterConfig = { ...emitterConfig, ...config };
};
function getEmitterConnection(config) {
  return new Promise((resolve, reject) => {
    const emitterClient = (0, import_emitter_io.connect)(config);
    emitterClient.on(import_emitter_io.EmitterEvents.connect, function() {
      resolve(emitterClient);
    });
    emitterClient.on(import_emitter_io.EmitterEvents.error, function(e) {
      console.log("emitter events error", e);
      reject(null);
    });
  });
}
function getReefscanEventConnIdent(config) {
  return config.host + config.port?.toString() + config.secure?.toString();
}
const getIndexerEmitterConn$ = (config) => {
  const connConfig = { ...config };
  const connIdent = getReefscanEventConnIdent(connConfig);
  if (!emitterConnObsCache.has(connIdent)) {
    const emitterConn2 = (0, import_rxjs.of)(connConfig).pipe(
      (0, import_rxjs.switchMap)((config2) => {
        return (0, import_rxjs.from)(getEmitterConnection(config2)).pipe(
          (0, import_rxjs.switchMap)((emitterConn3) => {
            const subj = new import_rxjs.ReplaySubject(1);
            emitterConn3.on(import_emitter_io.EmitterEvents.disconnect, function() {
              console.log("reefscan events disconnected");
              subj.next(null);
            });
            subj.next(emitterConn3);
            return subj.pipe(
              (0, import_rxjs.map)((eConn) => {
                if (!eConn) {
                  throw new Error("emitter disconnected");
                }
                return eConn;
              })
            );
          }),
          (0, import_rxjs.catchError)((err, caught) => {
            console.log("reefscanEventsConn$ ERR=", err);
            return (0, import_rxjs.merge)((0, import_rxjs.of)(null), (0, import_rxjs.timer)(8e3).pipe((0, import_rxjs.switchMap)(() => caught)));
          })
        );
      }),
      (0, import_operators.shareReplay)(1)
    );
    emitterConnObsCache.set(connIdent, emitterConn2);
  }
  return emitterConnObsCache.get(connIdent);
};
const getIndexerEventsNetworkChannel = (network) => {
  const INDEXER_EVENTS_CHANNEL_ROOT = "reef-indexer/";
  const channel = INDEXER_EVENTS_CHANNEL_ROOT + network + "/";
  return channel;
};
const getConnectedIndexerEmitter$ = (config) => getIndexerEmitterConn$(config).pipe(
  (0, import_operators.filter)((v) => {
    if (!v) {
      console.log("indexer events waiting for connection");
    } else {
      console.log("indexer events connection ok");
    }
    return !!v;
  }),
  (0, import_operators.shareReplay)(1)
);
const getEmitterChannel$ = (channel, config) => {
  const eventsConf = config ? { ...config } : { ...emitterConfig };
  const channelIdent = getReefscanEventConnIdent(eventsConf) + channel;
  if (!emitterChannelObsCache.has(channelIdent)) {
    const ch$ = getConnectedIndexerEmitter$(eventsConf).pipe(
      (0, import_rxjs.switchMap)((emitterConn2) => {
        return new import_rxjs.Observable((obs) => {
          emitterConn2.subscribe({
            key: EMITTER_READ_KEY,
            channel
          });
          emitterConn2.on(import_emitter_io.EmitterEvents.message, function(event) {
            if (event.channel === channel) {
              const latestBlock = JSON.parse(event.asString());
              if (latestBlock.blockHeight >= -1) {
                obs.next(latestBlock);
              }
            }
          });
          return () => {
            console.log("unsubs from emitter channel=", channel);
            emitterConn2.unsubscribe({ key: EMITTER_READ_KEY, channel });
          };
        });
      }),
      (0, import_rxjs.share)()
    );
    emitterChannelObsCache.set(channelIdent, ch$);
  }
  return emitterChannelObsCache.get(channelIdent);
};
const getBlockDataEmitter = (selNetwork$, emitterConfig2) => {
  return selNetwork$.pipe(
    (0, import_rxjs.switchMap)(
      (networkName) => getEmitterChannel$(
        getIndexerEventsNetworkChannel(networkName),
        emitterConfig2
      )
    ),
    (0, import_operators.shareReplay)(1)
  );
};
const getIndexerConnState$ = (config) => {
  const emitter$ = getIndexerEmitterConn$(config || emitterConfig);
  return emitter$.pipe((0, import_rxjs.map)((emitter) => ({ isConnected: !!emitter })));
};
const disconnectEmitter = (config) => {
  const emitter$ = getIndexerEmitterConn$(config || emitterConfig);
  return emitter$.pipe((0, import_rxjs.take)(1)).subscribe((emitter) => {
    if (emitter) {
      emitter.disconnect();
    }
  });
};
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  disconnectEmitter,
  emitterConfig,
  getBlockDataEmitter,
  getConnectedIndexerEmitter$,
  getIndexerConnState$,
  getIndexerEmitterConn$,
  getIndexerEventsNetworkChannel,
  setReefscanEventsConnConfig
});

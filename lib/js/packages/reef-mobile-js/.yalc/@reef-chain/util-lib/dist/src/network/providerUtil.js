var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
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
var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);
var providerUtil_exports = {};
__export(providerUtil_exports, {
  connectProvider: () => connectProvider,
  disconnectProvider: () => disconnectProvider,
  initProvider: () => initProvider,
  reconnectProvider: () => reconnectProvider
});
module.exports = __toCommonJS(providerUtil_exports);
var import_evm_provider = require("@reef-chain/evm-provider");
var import_api = require("@polkadot/api");
var import_rxjs = require("rxjs");
var import_reefState = require("../reefState");
async function initProvider(providerUrl, providerConnStateSubj, rpcConfig) {
  let newProvider;
  try {
    newProvider = new import_evm_provider.Provider({
      //@ts-ignore
      provider: new import_api.WsProvider(providerUrl, rpcConfig?.autoConnectMs)
    });
  } catch (e) {
    console.log("ERROR provider init=", e.message);
    throw new Error(e);
  }
  try {
    newProvider.api.on("connected", (v) => {
      console.log("util-lib providerConnected");
      providerConnStateSubj?.next({
        isConnected: true,
        status: {
          value: "connected",
          timestamp: (/* @__PURE__ */ new Date()).getTime()
          // !!! don't pass data from input parameters since can't be JSON encoded
          // data: v,
        }
      });
    });
    newProvider.api.on("error", (v) => {
      console.log("util-lib providerError");
      providerConnStateSubj?.next({
        isConnected: false,
        status: {
          value: "error",
          timestamp: (/* @__PURE__ */ new Date()).getTime()
          // !!! don't pass data from input parameters since can't be JSON encoded,
          // data: v
        }
      });
    });
    newProvider.api.on("disconnected", (v) => {
      console.log("util-lib providerDISConnected");
      providerConnStateSubj?.next({
        isConnected: false,
        status: {
          value: "disconnected",
          timestamp: (/* @__PURE__ */ new Date()).getTime()
          // !!! don't pass data from input parameters since can't be JSON encoded
          // data: v,
        }
      });
    });
    newProvider.api.on("ready", (_) => {
      console.log("util-lib providerReady");
      providerConnStateSubj?.next({
        isConnected: true,
        status: {
          value: "connected",
          timestamp: (/* @__PURE__ */ new Date()).getTime()
          // !!! don't pass data from input parameters since can't be JSON encoded
          // data: v,
        }
      });
    });
    await newProvider.api.isReadyOrError;
  } catch (e) {
    console.log("Provider isReadyOrError ERROR=", e.message);
    providerConnStateSubj?.next({
      isConnected: false,
      status: {
        value: "error",
        timestamp: (/* @__PURE__ */ new Date()).getTime(),
        data: e.message
      }
    });
    throw e;
  }
  return newProvider;
}
async function getReefStateProvider() {
  const provider = await Promise.race([
    (0, import_rxjs.firstValueFrom)(import_reefState.selectedProvider$),
    new Promise((resolve) => setTimeout(() => resolve(null), 50))
  ]);
  if (!provider) {
    return null;
  }
  return provider;
}
async function disconnectProvider(provider) {
  if (!provider) {
    provider = await getReefStateProvider();
  }
  if (provider) {
    const disconnected = new Promise((resolve, reject) => {
      provider.api.once("disconnected", (v) => {
        console.log("disconnected provider");
        resolve(true);
      });
    });
    try {
      await provider.api.isReadyOrError;
      provider.api.disconnect();
      return disconnected;
    } catch (e) {
      console.log("Provider disconnect err=", e.message);
      throw new Error(e);
    }
  }
  return false;
}
async function connectProvider(provider) {
  if (!provider) {
    provider = await getReefStateProvider();
  }
  if (provider) {
    try {
      const connected = await provider.api.isConnected;
      if (connected !== true) {
        await provider.api.connect();
      }
      return true;
    } catch (e) {
      console.log("Provider connect err=", e.message);
    }
  }
  return false;
}
async function reconnectProvider(provider) {
  if (!provider) {
    provider = await getReefStateProvider();
  }
  if (provider) {
    try {
      await disconnectProvider(provider);
      return new Promise((resolve, reject) => {
        setTimeout(async () => {
          try {
            await connectProvider(provider);
          } catch (e) {
            console.log("ERROR connecting provider", e.message);
            resolve(false);
          }
          resolve(true);
        }, 0);
      });
    } catch (e) {
      console.log("Provider reconnect err=", e.message);
    }
  }
  return false;
}
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  connectProvider,
  disconnectProvider,
  initProvider,
  reconnectProvider
});

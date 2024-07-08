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
var __reExport = (target, mod, secondTarget) => (__copyProps(target, mod, "default"), secondTarget && __copyProps(secondTarget, mod, "default"));
var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);
var extension_inject_exports = {};
__export(extension_inject_exports, {
  ExtensionsIdents: () => ExtensionsIdents,
  REEF_EASY_WALLET_IDENT: () => REEF_EASY_WALLET_IDENT,
  REEF_EXTENSION_IDENT: () => REEF_EXTENSION_IDENT,
  REEF_INJECTED_EVENT: () => REEF_INJECTED_EVENT,
  REEF_SNAP_IDENT: () => REEF_SNAP_IDENT,
  REEF_WALLET_CONNECT_IDENT: () => REEF_WALLET_CONNECT_IDENT,
  injectExtension: () => injectExtension,
  isInjected: () => isInjected,
  isInjectionStarted: () => isInjectionStarted,
  startInjection: () => startInjection
});
module.exports = __toCommonJS(extension_inject_exports);
__reExport(extension_inject_exports, require("./types"), module.exports);
const REEF_EXTENSION_IDENT = "reef";
const REEF_SNAP_IDENT = "reef-snap";
const REEF_EASY_WALLET_IDENT = "reef-easy-wallet";
const REEF_WALLET_CONNECT_IDENT = "reef-wallet-connect";
const ExtensionsIdents = [
  REEF_EXTENSION_IDENT,
  REEF_SNAP_IDENT,
  REEF_EASY_WALLET_IDENT,
  REEF_WALLET_CONNECT_IDENT
];
const REEF_INJECTED_EVENT = "reef-injected";
function injectExtension(enable, { name, version }) {
  const windowInject = window;
  if (windowInject) {
    windowInject.injectedWeb3 = windowInject.injectedWeb3 || {};
    windowInject.injectedWeb3[name] = {
      enable: (origin) => enable(origin),
      version
    };
  }
}
function isInjected(name) {
  const windowInject = window;
  return !!windowInject?.injectedWeb3 && !!windowInject?.injectedWeb3[name];
}
function isInjectionStarted(name) {
  const windowInject = window;
  return !!windowInject._reefInjectionStart && !!windowInject._reefInjectionStart[name];
}
function startInjection(name) {
  if (!window._reefInjectionStart) {
    window._reefInjectionStart = {};
  }
  window._reefInjectionStart[name] = true;
}
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  ExtensionsIdents,
  REEF_EASY_WALLET_IDENT,
  REEF_EXTENSION_IDENT,
  REEF_INJECTED_EVENT,
  REEF_SNAP_IDENT,
  REEF_WALLET_CONNECT_IDENT,
  injectExtension,
  isInjected,
  isInjectionStarted,
  startInjection,
  ...require("./types")
});

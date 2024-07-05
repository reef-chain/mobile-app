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
var initReefState_exports = {};
__export(initReefState_exports, {
  initReefState: () => initReefState
});
module.exports = __toCommonJS(initReefState_exports);
var import_networkState = require("./networkState");
var import_extensionState = require("./extensionState");
var import_network = require("../network/network");
var import_setAccounts = require("./account/setAccounts");
var import_nftUtils = require("./token/nftUtils");
var import_reefscanEvents = require("../utils/reefscanEvents");
const initReefState = ({
  network,
  extension,
  jsonAccounts,
  ipfsHashResolverFn,
  reefscanEventsConfig,
  rpcConfig
}) => {
  (0, import_nftUtils.setNftIpfsResolverFn)(ipfsHashResolverFn);
  if (reefscanEventsConfig) {
    (0, import_reefscanEvents.setReefscanEventsConnConfig)(reefscanEventsConfig);
  }
  if (rpcConfig) {
    (0, import_networkState.setRpcConfig)(rpcConfig);
  }
  (0, import_networkState.setSelectedNetwork)(network || import_network.AVAILABLE_NETWORKS.mainnet);
  (0, import_extensionState.setSelectedExtension)(extension);
  if (jsonAccounts) {
    import_setAccounts.accountsJsonSigningKeySubj.next(jsonAccounts.injectedSigner);
    (0, import_setAccounts.setAccounts)(jsonAccounts.accounts);
  }
};
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  initReefState
});

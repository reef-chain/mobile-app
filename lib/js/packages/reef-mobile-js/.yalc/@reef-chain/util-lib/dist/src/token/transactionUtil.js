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
var transactionUtil_exports = {};
__export(transactionUtil_exports, {
  getContractUrl: () => getContractUrl,
  getExtrinsicUrl: () => getExtrinsicUrl,
  getTransferUrl: () => getTransferUrl,
  handleErr: () => handleErr
});
module.exports = __toCommonJS(transactionUtil_exports);
var import_network = require("../network/network");
var import_txErrorUtil = require("../transaction/txErrorUtil");
const handleErr = (e, txIdent, txHash, txHandler, signer) => {
  let { message, code } = (0, import_txErrorUtil.toTxErrorCodeValue)(e);
  txHandler({
    txIdent,
    txHash,
    error: { message, code },
    addresses: [signer.address]
  });
};
const getExtrinsicUrl = (id, network = import_network.AVAILABLE_NETWORKS.mainnet) => `${network.reefscanUrl}/extrinsic/${id}`;
const getContractUrl = (address, network = import_network.AVAILABLE_NETWORKS.mainnet) => `${network.reefscanUrl}/contract/${address}`;
const getTransferUrl = (blockHeight, extrinsicIndex, eventIndex, network = import_network.AVAILABLE_NETWORKS.mainnet) => `${network.reefscanUrl}/transfer/${blockHeight}/${extrinsicIndex}/${eventIndex}`;
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  getContractUrl,
  getExtrinsicUrl,
  getTransferUrl,
  handleErr
});

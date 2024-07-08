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
var snap_exports = {};
__export(snap_exports, {
  SNAP_ID: () => SNAP_ID,
  connectSnap: () => connectSnap,
  getSnap: () => getSnap,
  getSnaps: () => getSnaps,
  sendToSnap: () => sendToSnap
});
module.exports = __toCommonJS(snap_exports);
const SNAP_ID = "npm:@reef-chain/reef-snap";
const getSnaps = async (provider) => await (provider ?? window.ethereum).request({
  method: "wallet_getSnaps"
});
const connectSnap = async () => {
  await window.ethereum.request({
    method: "wallet_requestSnaps",
    params: {
      [SNAP_ID]: {}
    }
  });
};
const getSnap = async () => {
  try {
    const snaps = await getSnaps();
    return Object.values(snaps).find((snap) => snap.id === SNAP_ID);
  } catch (error) {
    console.log("Failed to obtain installed snap", error);
    return void 0;
  }
};
const sendToSnap = async (message, request) => {
  const res = await window.ethereum.request({
    method: "wallet_invokeSnap",
    params: {
      snapId: SNAP_ID,
      request: {
        method: message,
        params: request || {}
      }
    }
  });
  return res;
};
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  SNAP_ID,
  connectSnap,
  getSnap,
  getSnaps,
  sendToSnap
});

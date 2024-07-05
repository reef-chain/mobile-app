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
var addressUtil_exports = {};
__export(addressUtil_exports, {
  getEvmAddress: () => getEvmAddress
});
module.exports = __toCommonJS(addressUtil_exports);
const getEvmAddress = async (address, provider) => {
  if (address.length !== 48 || address[0] !== "5") {
    return address;
  }
  const evmAddress = await provider.api.query.evmAccounts.evmAddresses(address);
  const addr = evmAddress.toString();
  if (!addr) {
    throw new Error("EVM address does not exist");
  }
  return addr;
};
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  getEvmAddress
});

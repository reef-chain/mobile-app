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
var updateStateModel_exports = {};
__export(updateStateModel_exports, {
  UpdateDataType: () => UpdateDataType
});
module.exports = __toCommonJS(updateStateModel_exports);
var UpdateDataType = /* @__PURE__ */ ((UpdateDataType2) => {
  UpdateDataType2[UpdateDataType2["ACCOUNT_NATIVE_BALANCE"] = 0] = "ACCOUNT_NATIVE_BALANCE";
  UpdateDataType2[UpdateDataType2["ACCOUNT_TOKENS"] = 1] = "ACCOUNT_TOKENS";
  UpdateDataType2[UpdateDataType2["ACCOUNT_EVM_BINDING"] = 2] = "ACCOUNT_EVM_BINDING";
  return UpdateDataType2;
})(UpdateDataType || {});
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  UpdateDataType
});

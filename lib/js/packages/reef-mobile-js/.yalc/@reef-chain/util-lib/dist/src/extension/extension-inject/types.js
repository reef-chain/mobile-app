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
var types_exports = {};
__export(types_exports, {
  ReefSignerStatus: () => ReefSignerStatus,
  ReefVM: () => ReefVM
});
module.exports = __toCommonJS(types_exports);
var ReefVM = /* @__PURE__ */ ((ReefVM2) => {
  ReefVM2[ReefVM2["NATIVE"] = 0] = "NATIVE";
  ReefVM2[ReefVM2["EVM"] = 1] = "EVM";
  return ReefVM2;
})(ReefVM || {});
var ReefSignerStatus = /* @__PURE__ */ ((ReefSignerStatus2) => {
  ReefSignerStatus2["CONNECTING"] = "connecting";
  ReefSignerStatus2["NO_ACCOUNT_SELECTED"] = "no-account-selected";
  ReefSignerStatus2["SELECTED_NO_VM_CONNECTION"] = "selected-no-vm-connection";
  ReefSignerStatus2["OK"] = "OK";
  return ReefSignerStatus2;
})(ReefSignerStatus || {});
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  ReefSignerStatus,
  ReefVM
});

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
var errorUtil_exports = {};
__export(errorUtil_exports, {
  getAddressesErrorFallback: () => getAddressesErrorFallback
});
module.exports = __toCommonJS(errorUtil_exports);
var import_availableAddresses = require("./availableAddresses");
var import_rxjs = require("rxjs");
var import_statusDataObject = require("../model/statusDataObject");
function getAddressesErrorFallback(err, message, propName) {
  return import_availableAddresses.availableAddresses$.pipe(
    (0, import_rxjs.map)(
      (addrList) => (0, import_statusDataObject.toFeedbackDM)(
        addrList.map(
          (a) => (0, import_statusDataObject.toFeedbackDM)(
            a,
            import_statusDataObject.FeedbackStatusCode.ERROR,
            message + err.message,
            "balance"
          )
        ),
        import_statusDataObject.FeedbackStatusCode.ERROR,
        message + err.message,
        propName
      )
    )
  );
}
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  getAddressesErrorFallback
});

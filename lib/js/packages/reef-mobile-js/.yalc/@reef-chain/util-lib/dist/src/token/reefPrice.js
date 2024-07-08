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
var reefPrice_exports = {};
__export(reefPrice_exports, {
  reefPrice$: () => reefPrice$
});
module.exports = __toCommonJS(reefPrice_exports);
var import_rxjs = require("rxjs");
var import_prices = require("./prices");
var import_statusDataObject = require("../reefState/model/statusDataObject");
var import_force_reload_tokens = require("../reefState/token/force-reload-tokens");
const reefPrice$ = (0, import_rxjs.timer)(
  0,
  6e4
).pipe(
  (0, import_rxjs.mergeWith)(import_force_reload_tokens.forceReload$),
  (0, import_rxjs.switchMap)(async () => {
    try {
      const price = await (0, import_prices.getTokenPrice)(import_prices.PRICE_REEF_TOKEN_ID);
      return (0, import_statusDataObject.toFeedbackDM)(price, import_statusDataObject.FeedbackStatusCode.COMPLETE_DATA);
    } catch (err) {
      console.log("ERROR reefPrice$0=", err.message);
      return (0, import_statusDataObject.toFeedbackDM)(0, import_statusDataObject.FeedbackStatusCode.ERROR, err.message);
    }
  }),
  // map((price:number)=>toFeedbackDM(price, FeedbackStatusCode.COMPLETE_DATA)),
  (0, import_rxjs.startWith)((0, import_statusDataObject.toFeedbackDM)(0, import_statusDataObject.FeedbackStatusCode.LOADING, "Loading REEF price.")),
  (0, import_rxjs.catchError)((err) => {
    console.log("ERROR reefPrice$", err.message);
    return (0, import_rxjs.of)((0, import_statusDataObject.toFeedbackDM)(0, import_statusDataObject.FeedbackStatusCode.ERROR, err.message));
  }),
  (0, import_rxjs.shareReplay)(1)
);
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  reefPrice$
});

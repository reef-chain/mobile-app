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
var accountsLocallyUpdatedData_exports = {};
__export(accountsLocallyUpdatedData_exports, {
  accountsLocallyUpdatedData$: () => accountsLocallyUpdatedData$,
  onTxUpdateResetSigners: () => onTxUpdateResetSigners
});
module.exports = __toCommonJS(accountsLocallyUpdatedData_exports);
var import_rxjs = require("rxjs");
var import_operators = require("rxjs/operators");
var import_accountStateUtil = require("./accountStateUtil");
var import_setAccounts = require("./setAccounts");
var import_availableAddresses = require("./availableAddresses");
var import_statusDataObject = require("../model/statusDataObject");
var import_providerState = require("../providerState");
const accountsLocallyUpdatedData$ = import_setAccounts.updateSignersSubj.pipe(
  (0, import_operators.filter)((reloadCtx) => !!reloadCtx.updateActions.length),
  (0, import_rxjs.withLatestFrom)(import_availableAddresses.availableAddresses$, import_providerState.selectedProvider$),
  (0, import_rxjs.mergeScan)(
    (state, [updateCtx, signersInjected, provider]) => {
      const allSignersLatestUpdates = (0, import_accountStateUtil.replaceUpdatedSigners)(
        signersInjected.map(
          (s) => (0, import_statusDataObject.toFeedbackDM)(s, import_statusDataObject.FeedbackStatusCode.COMPLETE_DATA)
        ),
        state.allUpdated
      );
      return (0, import_rxjs.of)(updateCtx.updateActions || []).pipe(
        (0, import_rxjs.switchMap)(
          (updateActions) => (0, import_accountStateUtil.updateSignersEvmBindings)(
            updateActions,
            provider,
            allSignersLatestUpdates
          ).then((lastUpdated) => ({
            all: (0, import_accountStateUtil.replaceUpdatedSigners)(
              allSignersLatestUpdates,
              lastUpdated,
              true
            ),
            allUpdated: (0, import_accountStateUtil.replaceUpdatedSigners)(
              state.allUpdated,
              lastUpdated,
              true
            ),
            lastUpdated
          })).catch((err) => {
            console.log("ERROR WITH LOCALLY UPD=", err.message);
            return null;
          })
        )
      );
    },
    {
      all: [],
      allUpdated: [],
      lastUpdated: []
    }
  ),
  (0, import_operators.filter)((val) => !!val.lastUpdated.length),
  (0, import_rxjs.map)((val) => {
    return (0, import_statusDataObject.toFeedbackDM)(val.all, import_statusDataObject.FeedbackStatusCode.COMPLETE_DATA);
  }),
  (0, import_rxjs.catchError)(
    (err) => (0, import_rxjs.of)((0, import_statusDataObject.toFeedbackDM)([], import_statusDataObject.FeedbackStatusCode.ERROR, err.message))
  ),
  (0, import_rxjs.startWith)((0, import_statusDataObject.toFeedbackDM)([], import_statusDataObject.FeedbackStatusCode.LOADING)),
  (0, import_rxjs.shareReplay)(1)
);
const onTxUpdateResetSigners = (txUpdateData, updateActions) => {
  if (txUpdateData?.isInBlock || txUpdateData?.error) {
    const delay = txUpdateData.txTypeEvm ? 2e3 : 0;
    setTimeout(() => import_setAccounts.updateSignersSubj.next({ updateActions }), delay);
  }
};
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  accountsLocallyUpdatedData$,
  onTxUpdateResetSigners
});

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
var accountsWithUpdatedChainDataBalances_exports = {};
__export(accountsWithUpdatedChainDataBalances_exports, {
  accountsWithUpdatedChainDataBalances$: () => accountsWithUpdatedChainDataBalances$
});
module.exports = __toCommonJS(accountsWithUpdatedChainDataBalances_exports);
var import_rxjs = require("rxjs");
var import_providerState = require("../providerState");
var import_ethers = require("ethers");
var import_availableAddresses = require("./availableAddresses");
var import_statusDataObject = require("../model/statusDataObject");
var import_errorUtil = require("./errorUtil");
const getUpdatedAccountChainBalances$ = (providerAndSigners) => {
  const signers = providerAndSigners[1];
  return (0, import_rxjs.of)(providerAndSigners).pipe(
    (0, import_rxjs.switchMap)((provAndSigs) => {
      const provider = provAndSigs[0];
      if (!provider) {
        const signers2 = provAndSigs[1];
        return (0, import_rxjs.merge)((0, import_rxjs.of)(signers2), import_rxjs.NEVER).pipe(
          (0, import_rxjs.map)(
            (sgs) => (0, import_statusDataObject.toFeedbackDM)(
              sgs.map(
                (s) => (0, import_statusDataObject.toFeedbackDM)(
                  s,
                  import_statusDataObject.FeedbackStatusCode.PARTIAL_DATA_LOADING,
                  "Connecting to chain.",
                  "balance"
                )
              ),
              import_statusDataObject.FeedbackStatusCode.PARTIAL_DATA_LOADING,
              "Connecting to chain and loading balances."
            )
          )
        );
      }
      return (0, import_rxjs.of)(provAndSigs).pipe(
        (0, import_rxjs.mergeScan)(
          (state, [prov, sigs]) => {
            if (state.unsub) {
              state.unsub();
            }
            const distinctSignerAddresses = sigs.map((s) => s.address).reduce((distinctAddrList, curr) => {
              if (distinctAddrList.indexOf(curr) < 0) {
                distinctAddrList.push(curr);
              }
              return distinctAddrList;
            }, []);
            return prov.api.query.system.account.multi(distinctSignerAddresses, (balances) => {
              const balancesByAddr = balances.map(({ data }, index) => ({
                address: distinctSignerAddresses[index],
                balance: data.free.toString()
              }));
              state.balancesByAddressSubj.next({
                balances: balancesByAddr,
                signers: sigs
              });
            }).then((unsub) => {
              state.unsub = unsub;
              return state;
            });
          },
          {
            unsub: null,
            balancesByAddressSubj: new import_rxjs.ReplaySubject(1)
          }
        ),
        (0, import_rxjs.distinctUntilChanged)(
          (prev, curr) => prev.balancesByAddressSubj !== curr.balancesByAddressSubj
        ),
        (0, import_rxjs.switchMap)(
          (v) => v.balancesByAddressSubj.pipe(
            (0, import_rxjs.startWith)(
              (0, import_statusDataObject.toFeedbackDM)(
                signers.map(
                  (s) => (0, import_statusDataObject.toFeedbackDM)(
                    s,
                    import_statusDataObject.FeedbackStatusCode.PARTIAL_DATA_LOADING,
                    "Loading balace",
                    "balance"
                  )
                ),
                import_statusDataObject.FeedbackStatusCode.PARTIAL_DATA_LOADING,
                "Loading chain balances."
              )
            ),
            (0, import_rxjs.catchError)(
              (err) => (0, import_rxjs.of)(
                (0, import_statusDataObject.toFeedbackDM)(
                  signers.map(
                    (s) => (0, import_statusDataObject.toFeedbackDM)(
                      s,
                      import_statusDataObject.FeedbackStatusCode.ERROR,
                      "ERROR loading chain balance = " + err.message,
                      "balance"
                    )
                  ),
                  import_statusDataObject.FeedbackStatusCode.ERROR,
                  "Error loading balance from chain = " + err.message,
                  "balance"
                )
              )
            )
          )
        )
      );
    })
  );
};
const accountsWithUpdatedChainDataBalances$ = (0, import_rxjs.combineLatest)([import_providerState.instantProvider$, import_availableAddresses.availableAddresses$]).pipe(
  (0, import_rxjs.switchMap)((provider_accs) => getUpdatedAccountChainBalances$(provider_accs)),
  (0, import_rxjs.map)(
    (balancesAndSigners) => {
      if ((0, import_statusDataObject.isFeedbackDM)(balancesAndSigners)) {
        return balancesAndSigners;
      }
      const balAndSig = balancesAndSigners;
      const balances_sdo = balAndSig.signers.map((sig) => {
        const bal = balAndSig.balances.find(
          (b) => b.address === sig.address
        );
        if (bal && (!sig.balance || !import_ethers.BigNumber.from(bal.balance).eq(sig.balance))) {
          return {
            ...sig,
            balance: import_ethers.BigNumber.from(bal.balance)
          };
        }
        return sig;
      }).map(
        (acc) => (0, import_statusDataObject.toFeedbackDM)(
          acc,
          import_statusDataObject.FeedbackStatusCode.COMPLETE_DATA,
          "Balance set",
          "balance"
        )
      );
      return (0, import_statusDataObject.toFeedbackDM)(
        balances_sdo,
        import_statusDataObject.FeedbackStatusCode.COMPLETE_DATA,
        "Balance set"
      );
    }
  ),
  (0, import_rxjs.catchError)(
    (err) => (0, import_errorUtil.getAddressesErrorFallback)(err, "Error chain balance=", "balance")
  ),
  (0, import_rxjs.shareReplay)(1)
);
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  accountsWithUpdatedChainDataBalances$
});

var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __export = (target, all) => {
  for (var name in all)
    __defProp(target, name, { get: all[name], enumerable: true });
};
var __copyProps = (to, from2, except, desc) => {
  if (from2 && typeof from2 === "object" || typeof from2 === "function") {
    for (let key of __getOwnPropNames(from2))
      if (!__hasOwnProp.call(to, key) && key !== except)
        __defProp(to, key, { get: () => from2[key], enumerable: !(desc = __getOwnPropDesc(from2, key)) || desc.enumerable });
  }
  return to;
};
var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);
var tokenState_rx_exports = {};
__export(tokenState_rx_exports, {
  allTokenBalances_status$: () => allTokenBalances_status$,
  selectedNFTs_status$: () => selectedNFTs_status$,
  selectedPools_status$: () => selectedPools_status$,
  selectedTokenBalances_status$: () => selectedTokenBalances_status$,
  selectedTokenPrices_status$: () => selectedTokenPrices_status$,
  selectedTransactionHistory_status$: () => selectedTransactionHistory_status$
});
module.exports = __toCommonJS(tokenState_rx_exports);
var import_rxjs = require("rxjs");
var import_reefPrice = require("../token/reefPrice");
var import_selectedAccountTokenBalances = require("./token/selectedAccountTokenBalances");
var import_selectedAccount = require("./account/selectedAccount");
var import_networkState = require("./networkState");
var import_selectedAccountAddressChange = require("./account/selectedAccountAddressChange");
var import_pools = require("../pools/pools");
var import_statusDataObject = require("./model/statusDataObject");
var import_nftUtils = require("./token/nftUtils");
var import_transferHistory = require("./token/transferHistory");
var import_accountSignerUtils = require("../account/accountSignerUtils");
var import_tokenUtil = require("./token/tokenUtil");
var import_dex = require("../network/dex");
var import_operators = require("rxjs/operators");
var import_ethers = require("ethers");
var import_providerState = require("./providerState");
var import_reloadTokenState = require("./token/reloadTokenState");
var import_latestBlock = require("../reefState/latestBlock");
var import_httpClient = require("../graphql/httpClient");
var import_force_reload_tokens = require("./token/force-reload-tokens");
var import_latestBlockModel = require("./latestBlockModel");
const reloadingValues$ = (0, import_rxjs.combineLatest)([
  import_networkState.selectedNetwork$,
  import_selectedAccountAddressChange.selectedAccountAddressChange$,
  import_force_reload_tokens.forceReload$
]).pipe((0, import_rxjs.shareReplay)(1));
const selectedAccountReefBalance$ = import_selectedAccount.selectedAccount_status$.pipe(
  (0, import_rxjs.map)((acc) => {
    return acc?.data.balance;
  }),
  (0, import_operators.filter)((bal) => !!bal && bal.gt(import_ethers.BigNumber.from("0"))),
  (0, import_rxjs.startWith)(void 0),
  (0, import_rxjs.shareReplay)(1)
);
const selectedTokenBalances_status$ = (0, import_rxjs.combineLatest)([
  import_httpClient.httpClientInstance$,
  import_selectedAccountAddressChange.selectedAccountAddressChange$,
  import_force_reload_tokens.forceReload$,
  import_reloadTokenState.selectedAccountFtBalanceUpdate$.pipe((0, import_rxjs.startWith)(true))
]).pipe(
  (0, import_rxjs.switchMap)((vals) => {
    const [httpClient, signer, forceReload, _] = vals;
    return (0, import_latestBlock.getLatestBlockAccountUpdates$)(
      [signer.data.address],
      [import_latestBlockModel.AccountIndexedTransactionType.REEF20_TRANSFER]
    ).pipe(
      (0, import_rxjs.startWith)(true),
      (0, import_rxjs.switchMap)((_2) => {
        return (0, import_selectedAccountTokenBalances.loadAccountTokens_sdo)(vals).pipe(
          (0, import_rxjs.switchMap)(
            (tkns) => {
              return (0, import_rxjs.combineLatest)([
                (0, import_rxjs.of)(tkns),
                selectedAccountReefBalance$
              ]).pipe(
                (0, import_rxjs.map)(
                  (arrVal) => (0, import_selectedAccountTokenBalances.replaceReefBalanceFromAccount)(arrVal[0], arrVal[1])
                )
              );
            }
          ),
          (0, import_rxjs.catchError)((err) => {
            console.log("ERROR2 selectedTokenBalances_status$=", err);
            return (0, import_rxjs.of)((0, import_statusDataObject.toFeedbackDM)([], import_statusDataObject.FeedbackStatusCode.ERROR, err.message));
          })
        );
      }),
      (0, import_rxjs.catchError)((err) => {
        console.log("ERROR0 selectedTokenBalances_status$=", err);
        return (0, import_rxjs.of)((0, import_statusDataObject.toFeedbackDM)([], import_statusDataObject.FeedbackStatusCode.ERROR, err.message));
      })
    );
  }),
  (0, import_rxjs.mergeWith)(
    reloadingValues$.pipe(
      (0, import_rxjs.map)(() => (0, import_statusDataObject.toFeedbackDM)([], import_statusDataObject.FeedbackStatusCode.LOADING))
    )
  ),
  (0, import_rxjs.catchError)((err) => {
    console.log("ERROR1 selectedTokenBalances_status$=", err.message);
    return (0, import_rxjs.of)((0, import_statusDataObject.toFeedbackDM)([], import_statusDataObject.FeedbackStatusCode.ERROR, err.message));
  }),
  (0, import_rxjs.shareReplay)(1)
);
const allTokenBalances_status$ = (0, import_rxjs.combineLatest)([
  import_httpClient.httpClientInstance$,
  import_force_reload_tokens.forceReload$,
  import_reloadTokenState.selectedAccountFtBalanceUpdate$.pipe((0, import_rxjs.startWith)(true))
]).pipe(
  (0, import_rxjs.switchMap)((vals) => {
    const [httpClient, forceReload, _] = vals;
    return (0, import_latestBlock.getLatestBlockAccountUpdates$)(
      [],
      [import_latestBlockModel.AccountIndexedTransactionType.REEF20_TRANSFER]
    ).pipe(
      (0, import_rxjs.startWith)(true),
      (0, import_rxjs.switchMap)((_2) => {
        return (0, import_selectedAccountTokenBalances.loadAllTokens_sdo)(vals).pipe(
          (0, import_rxjs.switchMap)(
            (tkns) => {
              return (0, import_rxjs.combineLatest)([
                (0, import_rxjs.of)(tkns),
                selectedAccountReefBalance$
              ]).pipe(
                (0, import_rxjs.map)(
                  (arrVal) => (0, import_selectedAccountTokenBalances.replaceReefBalanceFromAccount)(arrVal[0], arrVal[1])
                )
              );
            }
          ),
          (0, import_rxjs.catchError)((err) => {
            console.log("ERROR2 selectedTokenBalances_status$=", err);
            return (0, import_rxjs.of)((0, import_statusDataObject.toFeedbackDM)([], import_statusDataObject.FeedbackStatusCode.ERROR, err.message));
          })
        );
      }),
      (0, import_rxjs.catchError)((err) => {
        console.log("ERROR0 selectedTokenBalances_status$=", err);
        return (0, import_rxjs.of)((0, import_statusDataObject.toFeedbackDM)([], import_statusDataObject.FeedbackStatusCode.ERROR, err.message));
      })
    );
  }),
  (0, import_rxjs.mergeWith)(
    reloadingValues$.pipe(
      (0, import_rxjs.map)(() => (0, import_statusDataObject.toFeedbackDM)([], import_statusDataObject.FeedbackStatusCode.LOADING))
    )
  ),
  (0, import_rxjs.catchError)((err) => {
    console.log("ERROR1 selectedTokenBalances_status$=", err.message);
    return (0, import_rxjs.of)((0, import_statusDataObject.toFeedbackDM)([], import_statusDataObject.FeedbackStatusCode.ERROR, err.message));
  }),
  (0, import_rxjs.shareReplay)(1)
);
const selectedPools_status$ = (0, import_rxjs.combineLatest)([
  selectedTokenBalances_status$,
  import_providerState.selectedNetworkProvider$,
  import_selectedAccountAddressChange.selectedAccountAddressChange$
]).pipe(
  (0, import_rxjs.switchMap)(
    (valArr) => {
      const [tkns, networkProvider, signer] = valArr;
      if (!signer) {
        return (0, import_rxjs.of)(
          (0, import_statusDataObject.toFeedbackDM)(
            [],
            import_statusDataObject.FeedbackStatusCode.MISSING_INPUT_VALUES,
            "No pools signer"
          )
        );
      }
      return (0, import_rxjs.from)(
        (0, import_accountSignerUtils.getReefAccountSigner)(signer.data, networkProvider.provider)
      ).pipe(
        (0, import_rxjs.switchMap)(
          (sig) => (0, import_pools.fetchPools$)(
            tkns.data,
            sig,
            (0, import_dex.getReefswapNetworkConfig)(networkProvider.network).factoryAddress
          ).pipe(
            (0, import_rxjs.map)(
              (poolsArr) => (0, import_statusDataObject.toFeedbackDM)(
                poolsArr || [],
                poolsArr?.length ? (0, import_statusDataObject.collectFeedbackDMStatus)(poolsArr) : import_statusDataObject.FeedbackStatusCode.NOT_SET
              )
            )
          )
        )
      );
    }
  ),
  (0, import_rxjs.mergeWith)(
    reloadingValues$.pipe(
      (0, import_rxjs.map)(() => (0, import_statusDataObject.toFeedbackDM)([], import_statusDataObject.FeedbackStatusCode.LOADING))
    )
  ),
  (0, import_rxjs.shareReplay)(1)
);
const selectedTokenPrices_status$ = (0, import_rxjs.combineLatest)([
  selectedTokenBalances_status$,
  import_reefPrice.reefPrice$,
  selectedPools_status$
]).pipe(
  (0, import_rxjs.map)(import_tokenUtil.toTokensWithPrice_sdo),
  (0, import_rxjs.mergeWith)(
    reloadingValues$.pipe(
      (0, import_rxjs.map)(() => (0, import_statusDataObject.toFeedbackDM)([], import_statusDataObject.FeedbackStatusCode.LOADING))
    )
  ),
  (0, import_rxjs.catchError)((err) => {
    console.log("ERROR selectedTokenPrices_status$", err.message);
    return (0, import_rxjs.of)((0, import_statusDataObject.toFeedbackDM)([], import_statusDataObject.FeedbackStatusCode.ERROR, err.message));
  }),
  (0, import_rxjs.shareReplay)(1)
);
const selectedNFTs_status$ = (0, import_rxjs.combineLatest)([
  import_httpClient.httpClientInstance$,
  import_selectedAccountAddressChange.selectedAccountAddressChange$,
  import_force_reload_tokens.forceReload$,
  import_reloadTokenState.selectedAccountNftBalanceUpdate$.pipe((0, import_rxjs.startWith)(true))
]).pipe(
  (0, import_rxjs.switchMap)((v) => (0, import_nftUtils.loadSignerNfts)(v)),
  (0, import_rxjs.mergeWith)(
    reloadingValues$.pipe(
      (0, import_rxjs.map)(() => (0, import_statusDataObject.toFeedbackDM)([], import_statusDataObject.FeedbackStatusCode.LOADING))
    )
  ),
  (0, import_rxjs.catchError)(
    (err) => (0, import_rxjs.of)((0, import_statusDataObject.toFeedbackDM)([], import_statusDataObject.FeedbackStatusCode.ERROR, err.message))
  ),
  (0, import_rxjs.shareReplay)(1)
);
const selectedTransactionHistory_status$ = (0, import_rxjs.combineLatest)([
  import_httpClient.httpClientInstance$,
  import_selectedAccountAddressChange.selectedAccountAddressChange$,
  import_networkState.selectedNetwork$,
  import_providerState.selectedProvider$,
  import_force_reload_tokens.forceReload$,
  import_reloadTokenState.selectedAccountAnyBalanceUpdate$.pipe((0, import_rxjs.startWith)(true))
]).pipe(
  (0, import_rxjs.switchMap)(import_transferHistory.loadTransferHistory),
  (0, import_rxjs.map)(
    (vArr) => (0, import_statusDataObject.toFeedbackDM)(vArr, import_statusDataObject.FeedbackStatusCode.COMPLETE_DATA, "History loaded")
  ),
  (0, import_rxjs.mergeWith)(
    reloadingValues$.pipe(
      (0, import_rxjs.map)(() => (0, import_statusDataObject.toFeedbackDM)([], import_statusDataObject.FeedbackStatusCode.LOADING))
    )
  ),
  (0, import_rxjs.catchError)((err, _) => {
    console.log("selectedTransactionHistory_status$ ERR=", err.message);
    return (0, import_rxjs.of)((0, import_statusDataObject.toFeedbackDM)([], import_statusDataObject.FeedbackStatusCode.ERROR, err.message));
  }),
  (0, import_rxjs.shareReplay)(1)
);
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  allTokenBalances_status$,
  selectedNFTs_status$,
  selectedPools_status$,
  selectedTokenBalances_status$,
  selectedTokenPrices_status$,
  selectedTransactionHistory_status$
});

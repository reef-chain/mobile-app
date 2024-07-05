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
var accountsIndexedData_exports = {};
__export(accountsIndexedData_exports, {
  accountsWithUpdatedIndexedData$: () => accountsWithUpdatedIndexedData$
});
module.exports = __toCommonJS(accountsIndexedData_exports);
var import_rxjs = require("rxjs");
var import_accountsWithUpdatedChainDataBalances = require("./accountsWithUpdatedChainDataBalances");
var import_accountsLocallyUpdatedData = require("./accountsLocallyUpdatedData");
var import_availableAddresses = require("./availableAddresses");
var import_statusDataObject = require("../model/statusDataObject");
var import_errorUtil = require("./errorUtil");
var import_httpClient = require("../../graphql/httpClient");
var import_latestBlock = require("../latestBlock");
var import_accounts = require("../../graphql/accounts.gql");
var import_gqlUtil = require("../../graphql/gqlUtil");
var import_latestBlockModel = require("../latestBlockModel");
function toAccountEvmAddrData(result) {
  return result.data.accounts.map(
    (acc) => ({
      address: acc.id,
      isEvmClaimed: !!acc.evmAddress,
      evm_address: acc.evmAddress
    })
  );
}
const indexedAccountValues$ = (0, import_rxjs.combineLatest)([import_httpClient.httpClientInstance$, import_availableAddresses.availableAddresses$]).pipe(
  (0, import_rxjs.switchMap)(([httpClient, signers]) => {
    if (!signers) {
      return (0, import_rxjs.of)(
        (0, import_statusDataObject.toFeedbackDM)(
          [],
          import_statusDataObject.FeedbackStatusCode.MISSING_INPUT_VALUES,
          "Signer not set"
        )
      );
    }
    const addresses = signers.map((s) => s.address);
    return (0, import_latestBlock.getLatestBlockAccountUpdates$)(addresses, [
      import_latestBlockModel.AccountIndexedTransactionType.REEF_BIND_TX
    ]).pipe(
      (0, import_rxjs.startWith)(true),
      (0, import_rxjs.switchMap)((_) => (0, import_gqlUtil.queryGql$)(httpClient, (0, import_accounts.getEvmAddressQuery)(addresses)))
    );
  }),
  (0, import_rxjs.map)((result) => {
    if (result?.data?.accounts) {
      return (0, import_statusDataObject.toFeedbackDM)(
        toAccountEvmAddrData(result),
        import_statusDataObject.FeedbackStatusCode.COMPLETE_DATA,
        "Indexed evm address loaded"
      );
    }
    if ((0, import_statusDataObject.isFeedbackDM)(result)) {
      return result;
    }
    throw new Error("No result from EVM_ADDRESS_UPDATE_GQL");
  }),
  (0, import_rxjs.catchError)((err) => {
    console.log("ERROR indexedAccountValues$=", err.message);
    return (0, import_rxjs.of)((0, import_statusDataObject.toFeedbackDM)([], import_statusDataObject.FeedbackStatusCode.ERROR, err.message));
  }),
  (0, import_rxjs.startWith)((0, import_statusDataObject.toFeedbackDM)([], import_statusDataObject.FeedbackStatusCode.LOADING)),
  (0, import_rxjs.shareReplay)(1)
);
const accountsWithUpdatedIndexedData$ = (0, import_rxjs.combineLatest)([
  import_accountsWithUpdatedChainDataBalances.accountsWithUpdatedChainDataBalances$,
  import_accountsLocallyUpdatedData.accountsLocallyUpdatedData$,
  indexedAccountValues$
]).pipe(
  (0, import_rxjs.scan)(
    (state, [accountsWithChainBalance, locallyUpdated, indexed]) => {
      let updateBindValues = [];
      if (state.lastlocallyUpdated !== locallyUpdated) {
        updateBindValues = locallyUpdated.data.map(
          (updSigner) => (0, import_statusDataObject.toFeedbackDM)(
            {
              address: updSigner.data.address,
              isEvmClaimed: updSigner.data.isEvmClaimed,
              evmAddress: updSigner.data.evmAddress
            },
            updSigner.getStatusList()
          )
        );
      } else if (state.lastIndexed !== indexed) {
        updateBindValues = indexed.data.map(
          (updSigner) => (0, import_statusDataObject.toFeedbackDM)(
            {
              address: updSigner.address,
              isEvmClaimed: !!updSigner.evm_address,
              evmAddress: updSigner.evm_address
            },
            indexed.getStatusList()
          )
        );
      } else {
        updateBindValues = state.lastSigners.data.map(
          (updSigner) => (0, import_statusDataObject.toFeedbackDM)(
            {
              address: updSigner.data.address,
              isEvmClaimed: updSigner.data.isEvmClaimed,
              evmAddress: updSigner.data.evmAddress
            },
            updSigner.getStatusList()
          )
        );
      }
      updateBindValues.forEach((updVal) => {
        const signer = accountsWithChainBalance.data.find(
          (sig) => sig.data.address === updVal.data.address
        );
        if (signer) {
          const isEvmClaimedPropName = "isEvmClaimed";
          const resetEvmClaimedStat = signer.getStatusList().filter((stat) => stat.propName != isEvmClaimedPropName);
          updVal.getStatusList().forEach((updStat) => {
            resetEvmClaimedStat.push({
              propName: isEvmClaimedPropName,
              code: updStat.code
            });
          });
          if (updVal.hasStatus(import_statusDataObject.FeedbackStatusCode.COMPLETE_DATA)) {
            signer.data.isEvmClaimed = !!updVal.data.isEvmClaimed;
            signer.data.evmAddress = updVal.data.evmAddress;
          }
          signer.setStatus(resetEvmClaimedStat);
        }
      });
      return {
        signers: accountsWithChainBalance,
        lastlocallyUpdated: locallyUpdated,
        lastIndexed: indexed,
        lastSigners: accountsWithChainBalance
      };
    },
    {
      signers: (0, import_statusDataObject.toFeedbackDM)([], import_statusDataObject.FeedbackStatusCode.LOADING),
      lastlocallyUpdated: (0, import_statusDataObject.toFeedbackDM)([], import_statusDataObject.FeedbackStatusCode.LOADING),
      lastIndexed: (0, import_statusDataObject.toFeedbackDM)([], import_statusDataObject.FeedbackStatusCode.LOADING),
      lastSigners: (0, import_statusDataObject.toFeedbackDM)([], import_statusDataObject.FeedbackStatusCode.LOADING)
    }
  ),
  (0, import_rxjs.map)(
    (values) => values.signers
  ),
  (0, import_rxjs.catchError)(
    (err) => (0, import_errorUtil.getAddressesErrorFallback)(err, "Error signers updated data =")
  ),
  (0, import_rxjs.shareReplay)(1)
);
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  accountsWithUpdatedIndexedData$
});

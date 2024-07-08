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
var latestBlock_exports = {};
__export(latestBlock_exports, {
  _getBlockAccountTransactionUpdates$: () => _getBlockAccountTransactionUpdates$,
  getLatestBlockAccountUpdates$: () => getLatestBlockAccountUpdates$,
  getLatestBlockContractEvents$: () => getLatestBlockContractEvents$,
  getLatestBlockUpdates$: () => getLatestBlockUpdates$,
  publishIndexerEvent: () => publishIndexerEvent
});
module.exports = __toCommonJS(latestBlock_exports);
var import_rxjs = require("rxjs");
var import_operators = require("rxjs/operators");
var import_networkState = require("./networkState");
var import_reefscanEvents = require("../utils/reefscanEvents");
var import_latestBlockModel = require("./latestBlockModel");
const publishIndexerEvent = (blockData, network, key, config) => {
  const channel = (0, import_reefscanEvents.getIndexerEventsNetworkChannel)(network);
  (0, import_reefscanEvents.getConnectedIndexerEmitter$)(config || import_reefscanEvents.emitterConfig).pipe((0, import_rxjs.take)(1)).subscribe(
    (conn) => conn?.publish({ key, channel, message: JSON.stringify(blockData) })
  );
};
const getLatestBlockUpdates$ = (networkNameOrSelectedNetwork) => {
  let selNetwork$;
  if (!networkNameOrSelectedNetwork) {
    selNetwork$ = import_networkState.selectedNetwork$.pipe(
      (0, import_operators.filter)((network) => !!network),
      (0, import_rxjs.map)((v) => v.name)
    );
  } else {
    const rsNetwork = new import_rxjs.ReplaySubject(1);
    rsNetwork.next(networkNameOrSelectedNetwork);
    selNetwork$ = rsNetwork.asObservable();
  }
  return (0, import_reefscanEvents.getBlockDataEmitter)(selNetwork$);
};
const getUpdatedAccounts = (blockUpdates, filterTransactionType) => {
  const updatedAccounts = blockUpdates.updatedAccounts || {};
  switch (filterTransactionType) {
    case import_latestBlockModel.AccountIndexedTransactionType.REEF_NFT_TRANSFER:
      const reef1155Transfers = updatedAccounts.REEF1155Transfers || [];
      return Array.from(
        new Set(
          reef1155Transfers.concat(updatedAccounts.REEF721Transfers || [])
        )
      );
    case import_latestBlockModel.AccountIndexedTransactionType.REEF20_TRANSFER:
      return updatedAccounts.REEF20Transfers || [];
    case import_latestBlockModel.AccountIndexedTransactionType.REEF_BIND_TX:
      return updatedAccounts.boundEvm || [];
  }
  const allUpdated = Object.keys(updatedAccounts).reduce(
    (mergedArr, key) => {
      return mergedArr.concat(updatedAccounts[key] || []);
    },
    []
  );
  return Array.from(new Set(allUpdated));
};
function hasTransactionForTypes(blockUpdates, filterTransactionType) {
  if (!filterTransactionType.length) {
    return true;
  }
  return filterTransactionType.some((tt) => {
    const updatedAccounts = blockUpdates.updatedAccounts || {};
    switch (tt) {
      case import_latestBlockModel.AccountIndexedTransactionType.REEF20_TRANSFER:
        if (updatedAccounts.REEF20Transfers?.length) {
          return true;
        }
        break;
      case import_latestBlockModel.AccountIndexedTransactionType.REEF_NFT_TRANSFER:
        if (updatedAccounts.REEF721Transfers?.length || updatedAccounts.REEF1155Transfers?.length) {
          return true;
        }
        break;
      case import_latestBlockModel.AccountIndexedTransactionType.REEF_BIND_TX:
        if (updatedAccounts.boundEvm?.length) {
          return true;
        }
        break;
    }
    return false;
  });
}
const _getBlockAccountTransactionUpdates$ = (latestBlockUpdates$, filterAccountAddresses, filterTransactionType = import_latestBlockModel.allIndexedTransactions) => latestBlockUpdates$.pipe(
  (0, import_rxjs.map)((blockUpdates) => {
    if (filterAccountAddresses && filterAccountAddresses.some((addr) => addr.startsWith("0x"))) {
      console.warn("@reef-chain/util-lib // Only filter by native address.");
    }
    const allUpdatedAccounts = Array.from(
      new Set(
        filterTransactionType?.reduce((accs, txType) => {
          return accs.concat(getUpdatedAccounts(blockUpdates, txType));
        }, [])
      )
    ).filter((v) => !!v);
    if (!filterAccountAddresses || !filterAccountAddresses.filter((v) => !!v).length) {
      return {
        ...blockUpdates,
        addresses: allUpdatedAccounts
      };
    }
    const filtered = allUpdatedAccounts.filter(
      (addr) => filterAccountAddresses.some((a) => addr.trim() === a.trim())
    );
    return { ...blockUpdates, addresses: filtered };
  }),
  (0, import_operators.filter)(
    (v) => filterAccountAddresses && v != null && !!v.addresses.length || !filterAccountAddresses || !filterAccountAddresses?.length
  ),
  (0, import_operators.filter)(
    (value) => hasTransactionForTypes(
      value,
      filterTransactionType
    )
  ),
  (0, import_rxjs.catchError)((err) => {
    console.log("_getBlockAccountTransactionUpdates$ err=", err.message);
    return (0, import_rxjs.of)(null);
  })
);
const getLatestBlockAccountUpdates$ = (filterAccountAddresses, filterTransactionType, networkNameOrSelectedNetwork) => _getBlockAccountTransactionUpdates$(
  getLatestBlockUpdates$(networkNameOrSelectedNetwork),
  filterAccountAddresses,
  filterTransactionType
).pipe(
  (0, import_rxjs.catchError)((err) => {
    console.log("getLatestBlockAccountUpdates$ err=", err.message);
    return (0, import_rxjs.of)(null);
  })
);
const getLatestBlockContractEvents$ = (filterContractAddresses, networkNameOrReefStateNetwork) => {
  return getLatestBlockUpdates$(networkNameOrReefStateNetwork).pipe(
    (0, import_rxjs.map)((blockUpdates) => {
      if (!filterContractAddresses || !filterContractAddresses.length) {
        return blockUpdates.updatedContracts;
      }
      const updatedContracts = blockUpdates.updatedContracts.filter(
        (addr) => filterContractAddresses.some((a) => addr.trim() === a.trim())
      );
      if (!updatedContracts.length) {
        return null;
      }
      return {
        ...blockUpdates,
        addresses: updatedContracts
      };
    }),
    // eslint-disable-next-line @typescript-eslint/ban-ts-comment
    // @ts-ignore
    (0, import_operators.filter)((v) => !!v),
    (0, import_rxjs.catchError)((err) => {
      console.log("getLatestBlockContractEvents$ err=", err.message);
      return (0, import_rxjs.of)(null);
    })
  );
};
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  _getBlockAccountTransactionUpdates$,
  getLatestBlockAccountUpdates$,
  getLatestBlockContractEvents$,
  getLatestBlockUpdates$,
  publishIndexerEvent
});

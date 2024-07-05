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
var extension_dapp_exports = {};
__export(extension_dapp_exports, {
  SELECTED_EXTENSION_IDENT: () => SELECTED_EXTENSION_IDENT,
  isWeb3Injected: () => isWeb3Injected,
  web3Accounts: () => web3Accounts,
  web3AccountsSubscribe: () => web3AccountsSubscribe,
  web3Enable: () => web3Enable,
  web3EnablePromise: () => web3EnablePromise,
  web3FromAddress: () => web3FromAddress,
  web3FromSource: () => web3FromSource,
  web3ListRpcProviders: () => web3ListRpcProviders,
  web3UseRpcProvider: () => web3UseRpcProvider
});
module.exports = __toCommonJS(extension_dapp_exports);
var import_util = require("@polkadot/util");
var import_util_crypto = require("@polkadot/util-crypto");
var import_extension_inject = require("../extension-inject");
var import_util2 = require("./util");
var import_snap = require("../snap");
var import_inject = require("../snap/inject");
const SELECTED_EXTENSION_IDENT = "selected_extension_reef";
const win = typeof window !== "undefined" ? window : null;
if (win) {
  win.injectedWeb3 = win?.injectedWeb3 || {};
}
function web3IsInjected() {
  return win ? Object.keys(win.injectedWeb3).length !== 0 : false;
}
function throwError(method) {
  throw new Error(
    `${method}: web3Enable(originName) needs to be called before ${method}`
  );
}
function mapAccounts(source, list, ss58Format) {
  return list.map(
    ({ address, genesisHash, name, type }) => {
      const encodedAddress = address.length === 42 ? address : (0, import_util_crypto.encodeAddress)((0, import_util_crypto.decodeAddress)(address), ss58Format);
      return {
        address: encodedAddress,
        meta: { genesisHash, name, source },
        type
      };
    }
  );
}
let isWeb3Injected = web3IsInjected();
let web3EnablePromise = null;
function getWindowExtensions(originName) {
  if (!win) {
    return Promise.resolve([]);
  }
  return Promise.all(
    Object.entries(win.injectedWeb3).map(
      ([name, { enable, version }]) => Promise.all([
        Promise.resolve({ name, version }),
        enable(originName).catch((error) => {
          console.error(`Error initializing ${name}: ${error.message}`);
        })
      ])
    )
  );
}
const onReefInjectedPromise = () => new Promise((resolve) => {
  const listener = () => resolve(true);
  document.addEventListener(import_extension_inject.REEF_INJECTED_EVENT, listener, false);
  if ((0, import_extension_inject.isInjected)(import_extension_inject.REEF_EXTENSION_IDENT)) {
    document.removeEventListener(import_extension_inject.REEF_INJECTED_EVENT, listener);
    resolve(true);
  }
});
async function web3Enable(originName, compatInits = [], tryConnectSnap = false) {
  if (!originName) {
    throw new Error(
      "You must pass a name for your app to the web3Enable function"
    );
  }
  if (tryConnectSnap) {
    try {
      let snap = await (0, import_snap.getSnap)();
      if (!snap) {
        await (0, import_snap.connectSnap)();
        snap = await (0, import_snap.getSnap)();
      }
      if (snap) {
        (0, import_extension_inject.injectExtension)(import_inject.enableSnap, {
          name: import_extension_inject.REEF_SNAP_IDENT,
          version: snap.version
        });
      }
    } catch (e) {
    }
  }
  if ((0, import_extension_inject.isInjectionStarted)(import_extension_inject.REEF_EXTENSION_IDENT) && !(0, import_extension_inject.isInjected)(import_extension_inject.REEF_EXTENSION_IDENT)) {
    compatInits.push(onReefInjectedPromise);
  }
  const initCompat = compatInits.length ? Promise.all(compatInits.map((c) => c().catch(() => false))) : Promise.resolve([true]);
  let selectedWallet = void 0;
  try {
    selectedWallet = localStorage.getItem(SELECTED_EXTENSION_IDENT);
  } catch (e) {
  }
  web3EnablePromise = (0, import_util2.documentReadyPromise)(
    () => initCompat.then(
      () => getWindowExtensions(originName).then((values) => {
        return values.filter(
          (value) => !!value[1]
        ).map(([info, ext]) => {
          if (!ext.accounts.subscribe) {
            ext.accounts.subscribe = (cb) => {
              ext.accounts.get().then(cb).catch(console.error);
              return () => {
              };
            };
          }
          return { ...info, ...ext };
        }).sort((a, b) => {
          if (selectedWallet && a.name === selectedWallet) {
            return -1;
          }
          if (selectedWallet && b.name === selectedWallet) {
            return 1;
          }
          if (a.name === import_extension_inject.REEF_EXTENSION_IDENT) {
            return -1;
          }
          if (b.name === import_extension_inject.REEF_EXTENSION_IDENT) {
            return 1;
          }
          if (a.name === import_extension_inject.REEF_SNAP_IDENT) {
            return -1;
          }
          if (b.name === import_extension_inject.REEF_SNAP_IDENT) {
            return 1;
          }
          return 0;
        });
      }).catch(() => []).then((values) => {
        const names = values.map(
          ({ name, version }) => `${name}/${version}`
        );
        isWeb3Injected = web3IsInjected();
        console.log(
          `web3Enable: Enabled ${values.length} extension${values.length !== 1 ? "s" : ""}: ${names.join(", ")}`
        );
        return values;
      })
    )
  );
  return web3EnablePromise;
}
async function web3Accounts({
  accountType,
  ss58Format
} = {}) {
  if (!web3EnablePromise) {
    return throwError("web3Accounts");
  }
  const accounts = [];
  const injected = await web3EnablePromise;
  const retrieved = await Promise.all(
    injected.map(
      async ({
        accounts: accounts2,
        name: source
      }) => {
        try {
          const list = await accounts2.get();
          return mapAccounts(
            source,
            list.filter(
              ({ type }) => type && accountType ? accountType.includes(type) : true
            ),
            ss58Format
          );
        } catch (error) {
          return [];
        }
      }
    )
  );
  retrieved.forEach((result) => {
    accounts.push(...result);
  });
  return accounts;
}
async function web3AccountsSubscribe(cb, { ss58Format } = {}) {
  if (!web3EnablePromise) {
    return throwError("web3AccountsSubscribe");
  }
  const accounts = {};
  const triggerUpdate = () => cb(
    Object.entries(accounts).reduce(
      (result, [source, list]) => {
        result.push(...mapAccounts(source, list, ss58Format));
        return result;
      },
      []
    )
  );
  const unsubs = (await web3EnablePromise).map(
    ({ accounts: { subscribe }, name: source }) => subscribe((result) => {
      accounts[source] = result;
      triggerUpdate();
    })
  );
  return () => {
    unsubs.forEach((unsub) => {
      unsub();
    });
  };
}
async function web3FromSource(source) {
  if (!web3EnablePromise) {
    return throwError("web3FromSource");
  }
  const sources = await web3EnablePromise;
  const found = source && sources.find(({ name }) => name === source);
  if (!found) {
    throw new Error(`web3FromSource: Unable to find an injected ${source}`);
  }
  return found;
}
async function web3FromAddress(address) {
  if (!web3EnablePromise) {
    return throwError("web3FromAddress");
  }
  const accounts = await web3Accounts();
  let found;
  if (address) {
    const accountU8a = (0, import_util_crypto.decodeAddress)(address);
    found = accounts.find(
      (account) => (0, import_util.u8aEq)((0, import_util_crypto.decodeAddress)(account.address), accountU8a)
    );
  }
  if (!found) {
    throw new Error(`web3FromAddress: Unable to find injected ${address}`);
  }
  return web3FromSource(found.meta.source);
}
async function web3ListRpcProviders(source) {
  const { provider } = await web3FromSource(source);
  if (!provider) {
    console.warn(`Extension ${source} does not expose any provider`);
    return null;
  }
  return provider.listProviders();
}
async function web3UseRpcProvider(source, key) {
  const { provider } = await web3FromSource(source);
  if (!provider) {
    throw new Error(`Extension ${source} does not expose any provider`);
  }
  const meta = await provider.startProvider(key);
  return { meta, provider };
}
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  SELECTED_EXTENSION_IDENT,
  isWeb3Injected,
  web3Accounts,
  web3AccountsSubscribe,
  web3Enable,
  web3EnablePromise,
  web3FromAddress,
  web3FromSource,
  web3ListRpcProviders,
  web3UseRpcProvider
});

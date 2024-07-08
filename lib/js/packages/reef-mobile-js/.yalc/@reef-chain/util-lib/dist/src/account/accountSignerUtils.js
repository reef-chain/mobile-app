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
var accountSignerUtils_exports = {};
__export(accountSignerUtils_exports, {
  ReefSignerWrapper: () => ReefSignerWrapper,
  ReefSigningKeyWrapper: () => ReefSigningKeyWrapper,
  getAccountSigner: () => getAccountSigner,
  getReefAccountSigner: () => getReefAccountSigner
});
module.exports = __toCommonJS(accountSignerUtils_exports);
var import_evm_provider = require("@reef-chain/evm-provider");
var import_extension = require("../extension");
var import_setAccounts = require("../reefState/account/setAccounts");
const accountSourceSigners = /* @__PURE__ */ new Map();
const addressSigners = /* @__PURE__ */ new Map();
const getAccountInjectedSigner = async (source = import_extension.REEF_EXTENSION_IDENT) => {
  if (!accountSourceSigners.has(source)) {
    const signer = await (0, import_extension.web3FromSource)(source).then((injected) => injected?.signer).catch((err) => console.error("getAccountSigner error =", err));
    if (!signer) {
      console.warn("Can not get signer for source=" + source);
    }
    if (signer) {
      accountSourceSigners.set(source, signer);
    }
  }
  return accountSourceSigners.get(source);
};
const getReefAccountSigner = async ({ address, source }, provider) => {
  const src = import_setAccounts.accountsJsonSigningKeySubj.getValue() || source;
  return getAccountSigner(address, provider, src);
};
const getAccountSigner = async (address, provider, injSignerOrSource) => {
  let signingKey = injSignerOrSource;
  if (!injSignerOrSource || typeof injSignerOrSource === "string") {
    signingKey = await getAccountInjectedSigner(injSignerOrSource.toString());
  }
  if (!addressSigners.has(address)) {
    addressSigners.set(
      address,
      signingKey ? new ReefSignerWrapper(
        provider,
        address,
        // @ts-ignore
        new ReefSigningKeyWrapper(signingKey)
      ) : void 0
    );
  }
  return addressSigners.get(address);
};
class ReefSigningKeyWrapper {
  constructor(signingKey) {
    this.sigKey = signingKey;
  }
  // @ts-ignore
  signPayload(payload) {
    console.log("SIG PAYLOAD=", payload.method);
    return this.sigKey?.signPayload ? this.sigKey.signPayload(payload).then(
      (res) => {
        return res;
      },
      (rej) => {
        throw rej;
      }
    ) : Promise.reject("ReefSigningKeyWrapper - not implemented");
  }
  signRaw(raw) {
    return this.sigKey?.signRaw ? this.sigKey.signRaw(raw) : Promise.reject("ReefSigningKeyWrapper - not implemented");
  }
}
class ReefSignerWrapper extends import_evm_provider.Signer {
  constructor(provider, address, signingKey) {
    super(provider, address, signingKey);
  }
  sendTransaction(_transaction) {
    return super.sendTransaction(_transaction);
  }
}
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  ReefSignerWrapper,
  ReefSigningKeyWrapper,
  getAccountSigner,
  getReefAccountSigner
});

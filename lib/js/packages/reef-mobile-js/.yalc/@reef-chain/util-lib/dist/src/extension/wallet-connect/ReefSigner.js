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
var ReefSigner_exports = {};
__export(ReefSigner_exports, {
  default: () => ReefSigner
});
module.exports = __toCommonJS(ReefSigner_exports);
var import_evm_provider = require("@reef-chain/evm-provider");
var import_types = require("../extension-inject/types");
class ReefSigner {
  constructor(accounts, extSigner, injectedProvider) {
    this.selectedSignerStatus = null;
    this.isGetSignerMethodSubscribed = false;
    this.resolvesList = [];
    this.isSelectedAccountReceived = false;
    this.accounts = accounts;
    this.extSigningKey = extSigner;
    this.injectedProvider = injectedProvider;
  }
  subscribeSelectedAccount(cb) {
    return this.accounts.subscribe((accounts) => {
      cb(accounts.find((a) => a.isSelected));
    });
  }
  async getSelectedAccount() {
    const accounts = await this.accounts.get();
    return accounts.find((a) => a.isSelected);
  }
  subscribeSelectedSigner(cb, connectedVM = import_types.ReefVM.EVM) {
    const unsubProvFn = this.injectedProvider.subscribeSelectedNetworkProvider(
      (provider) => {
        this.selectedProvider = provider;
        this.onSelectedSignerParamUpdate(cb, connectedVM).then(
          () => {
          },
          () => {
            console.log("Error in onSelectedSignerParamUpdate");
          }
        );
      }
    );
    const unsubAccFn = this.subscribeSelectedAccount((account) => {
      this.isSelectedAccountReceived = true;
      if (!account || account?.address !== this.selectedSignerAccount?.address) {
        this.selectedSignerAccount = account;
        this.onSelectedSignerParamUpdate(cb, connectedVM).then(
          () => {
          },
          () => {
            console.log("Error in onSelectedSignerParamUpdate");
          }
        );
      }
    });
    return () => {
      unsubProvFn();
      unsubAccFn();
    };
  }
  async getSelectedSigner(connectedVM = import_types.ReefVM.EVM) {
    if (this.selectedSignerStatus) {
      return Promise.resolve({ ...this.selectedSignerStatus });
    }
    const retPromise = new Promise((resolve) => {
      this.resolvesList.push(resolve);
    });
    if (!this.isGetSignerMethodSubscribed) {
      this.isGetSignerMethodSubscribed = true;
      this.subscribeSelectedSigner((sig) => {
        if (!this.resolvesList.length) {
          return;
        }
        if (sig.status !== import_types.ReefSignerStatus.CONNECTING) {
          this.selectedSignerStatus = sig;
          this.resolvesList.forEach((resolve) => resolve({ ...sig }));
          this.resolvesList = [];
        }
      }, connectedVM);
    }
    return retPromise;
  }
  async onSelectedSignerParamUpdate(cb, connectedVM) {
    const selectedSigner = ReefSigner.createReefSigner(
      this.selectedSignerAccount,
      this.selectedProvider,
      this.extSigningKey
    );
    const hasVM = await ReefSigner.hasConnectedVM(connectedVM, selectedSigner);
    const responseStatus = this.getResponseStatus(
      selectedSigner,
      hasVM,
      connectedVM
    );
    if (responseStatus.status !== import_types.ReefSignerStatus.CONNECTING) {
      cb(responseStatus);
    }
  }
  getResponseStatus(selectedSigner, hasVM, requestedVM = import_types.ReefVM.NATIVE) {
    if (selectedSigner) {
      if (hasVM) {
        return {
          data: selectedSigner,
          status: import_types.ReefSignerStatus.OK,
          requestedVM
        };
      } else {
        return {
          data: void 0,
          status: import_types.ReefSignerStatus.SELECTED_NO_VM_CONNECTION,
          requestedVM
        };
      }
    } else if (this.selectedProvider && this.extSigningKey) {
      if (this.isSelectedAccountReceived && !this.selectedSignerAccount) {
        return {
          data: void 0,
          status: import_types.ReefSignerStatus.NO_ACCOUNT_SELECTED,
          requestedVM
        };
      }
    }
    return {
      data: void 0,
      status: import_types.ReefSignerStatus.CONNECTING,
      requestedVM
    };
  }
  static createReefSigner(selectedSignerAccount, selectedProvider, extSigner) {
    return selectedSignerAccount && selectedProvider && extSigner ? new import_evm_provider.Signer(
      selectedProvider,
      selectedSignerAccount.address,
      extSigner
    ) : void 0;
  }
  static async hasConnectedVM(connectedVM, signer) {
    if (!signer) {
      return false;
    }
    return !connectedVM || connectedVM === import_types.ReefVM.EVM && await signer?.isClaimed();
  }
}

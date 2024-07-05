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
var accountStateUtil_exports = {};
__export(accountStateUtil_exports, {
  getSignersToUpdate: () => getSignersToUpdate,
  isUpdateAll: () => isUpdateAll,
  replaceUpdatedSigners: () => replaceUpdatedSigners,
  updateSignersEvmBindings: () => updateSignersEvmBindings
});
module.exports = __toCommonJS(accountStateUtil_exports);
var import_updateStateModel = require("../model/updateStateModel");
var import_accountSignerUtils = require("../../account/accountSignerUtils");
var import_statusDataObject = require("../model/statusDataObject");
const getUpdAddresses = (updateType, updateActions) => {
  const typeUpdateActions = updateActions.filter((ua) => ua.type === updateType);
  if (typeUpdateActions.length === 0) {
    return null;
  }
  if (typeUpdateActions.some((tua) => !tua.address)) {
    return [];
  }
  return typeUpdateActions.map((ua) => ua.address);
};
const isUpdateAll = (addresses) => addresses?.length === 0;
const getSignersToUpdate = (updateType, updateActions, signers) => {
  const updAddresses = getUpdAddresses(updateType, updateActions);
  return isUpdateAll(updAddresses) ? signers : signers.filter((sig) => updAddresses?.some((addr) => addr === sig.address));
};
const replaceUpdatedSigners = (existingSigners = [], updatedSigners, appendNew) => {
  if (!appendNew && !existingSigners.length) {
    return existingSigners;
  }
  if (!updatedSigners || !updatedSigners.length) {
    return existingSigners;
  }
  const signers = existingSigners.map(
    (existingSig) => updatedSigners.find(
      (updSig) => updSig.data.address === existingSig.data.address
    ) || existingSig
  );
  if (!appendNew) {
    return signers;
  }
  updatedSigners.forEach((updS) => {
    if (!signers.some((s) => s.data.address === updS.data.address)) {
      signers.push(updS);
    }
  });
  return signers;
};
const updateSignersEvmBindings = (updateActions, provider, accounts_sdo = []) => {
  if (!accounts_sdo.length) {
    return Promise.resolve([]);
  }
  const updSigners = getSignersToUpdate(
    import_updateStateModel.UpdateDataType.ACCOUNT_EVM_BINDING,
    updateActions,
    accounts_sdo.map((s) => s.data)
  );
  return Promise.all(
    updSigners.map(
      async (sig) => {
        const signer = await (0, import_accountSignerUtils.getReefAccountSigner)(sig, provider);
        if (!signer) {
          return (0, import_statusDataObject.toFeedbackDM)(
            sig,
            import_statusDataObject.FeedbackStatusCode.MISSING_INPUT_VALUES,
            "ERROR: Can not get account signer."
          );
        }
        const isEvmClaimed = await signer.isClaimed();
        const evmAddress = isEvmClaimed ? await signer.queryEvmAddress() : "";
        return { isEvmClaimed, evmAddress };
      }
    )
  ).then(
    (claimed) => claimed.map(
      (isEvmClaimedData, i) => {
        if ((0, import_statusDataObject.isFeedbackDM)(isEvmClaimedData)) {
          return isEvmClaimedData;
        }
        const account = updSigners[i];
        return (0, import_statusDataObject.toFeedbackDM)(
          { ...account, ...isEvmClaimedData },
          import_statusDataObject.FeedbackStatusCode.COMPLETE_DATA
        );
      }
    )
  );
};
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  getSignersToUpdate,
  isUpdateAll,
  replaceUpdatedSigners,
  updateSignersEvmBindings
});

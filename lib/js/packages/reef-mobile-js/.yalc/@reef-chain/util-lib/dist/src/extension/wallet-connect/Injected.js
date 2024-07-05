var __create = Object.create;
var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __getProtoOf = Object.getPrototypeOf;
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
var __toESM = (mod, isNodeMode, target) => (target = mod != null ? __create(__getProtoOf(mod)) : {}, __copyProps(
  // If the importer is in node compatibility mode or this is not an ESM
  // file that has been converted to a CommonJS file using a Babel-
  // compatible transform (i.e. "__esModule" has not been set), then set
  // "default" to the CommonJS "module.exports" for node compatibility.
  isNodeMode || !mod || !mod.__esModule ? __defProp(target, "default", { value: mod, enumerable: true }) : target,
  mod
));
var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);
var Injected_exports = {};
__export(Injected_exports, {
  default: () => Injected_default
});
module.exports = __toCommonJS(Injected_exports);
var import_Accounts = __toESM(require("./Accounts"));
var import_Signer = __toESM(require("./Signer"));
var import_ReefProvider = __toESM(require("./ReefProvider"));
var import_ReefSigner = __toESM(require("./ReefSigner"));
class Injected_default {
  constructor(client, session) {
    this.accounts = new import_Accounts.default(session);
    this.signer = new import_Signer.default(client, session);
    this.reefProvider = new import_ReefProvider.default(session);
    this.reefSigner = new import_ReefSigner.default(
      this.accounts,
      this.signer,
      this.reefProvider
    );
  }
}

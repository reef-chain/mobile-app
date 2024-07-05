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
var Accounts_exports = {};
__export(Accounts_exports, {
  default: () => Accounts
});
module.exports = __toCommonJS(Accounts_exports);
let session;
class Accounts {
  constructor(_session) {
    session = _session;
  }
  get() {
    if (!session.namespaces.reef?.accounts?.length)
      return Promise.resolve([]);
    const addresses = Array.from(
      new Set(
        session.namespaces.reef.accounts.map((account) => account.split(":")[2])
      )
    );
    const accounts = addresses.map(
      (address, index) => ({ address, isSelected: index === 0 })
    );
    return Promise.resolve(accounts);
  }
  subscribe(cb) {
    let unsubs = false;
    this.get().then((val) => {
      if (!unsubs) {
        cb(val);
      }
    }).catch((error) => console.error(error));
    return () => {
      unsubs = true;
    };
  }
}

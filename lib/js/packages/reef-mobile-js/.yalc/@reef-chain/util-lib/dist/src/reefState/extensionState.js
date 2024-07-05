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
var extensionState_exports = {};
__export(extensionState_exports, {
  selectedExtension$: () => selectedExtension$,
  setSelectedExtension: () => setSelectedExtension
});
module.exports = __toCommonJS(extensionState_exports);
var import_rxjs = require("rxjs");
var import_extension = require("../extension");
const selectedExtensionSubj = new import_rxjs.ReplaySubject(
  1
);
const selectedExtension$ = selectedExtensionSubj.asObservable();
const setSelectedExtension = (extIdent) => {
  if (extIdent) {
    try {
      localStorage.setItem(import_extension.SELECTED_EXTENSION_IDENT, extIdent);
    } catch (e) {
    }
  }
  selectedExtensionSubj.next(extIdent);
};
selectedExtension$.subscribe(
  (extIdent) => console.log("SELECTED EXTENSION=", extIdent)
);
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  selectedExtension$,
  setSelectedExtension
});

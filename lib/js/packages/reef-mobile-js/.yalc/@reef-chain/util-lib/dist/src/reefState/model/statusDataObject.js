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
var statusDataObject_exports = {};
__export(statusDataObject_exports, {
  FeedbackStatusCode: () => FeedbackStatusCode,
  StatusDataObject: () => StatusDataObject,
  collectFeedbackDMStatus: () => collectFeedbackDMStatus,
  findMinStatusCode: () => findMinStatusCode,
  isFeedbackDM: () => isFeedbackDM,
  skipBeforeStatus$: () => skipBeforeStatus$,
  toFeedbackDM: () => toFeedbackDM
});
module.exports = __toCommonJS(statusDataObject_exports);
var import_rxjs = require("rxjs");
var FeedbackStatusCode = /* @__PURE__ */ ((FeedbackStatusCode2) => {
  FeedbackStatusCode2[FeedbackStatusCode2["_"] = 0] = "_";
  FeedbackStatusCode2[FeedbackStatusCode2["LOADING"] = 1] = "LOADING";
  FeedbackStatusCode2[FeedbackStatusCode2["PARTIAL_DATA_LOADING"] = 2] = "PARTIAL_DATA_LOADING";
  FeedbackStatusCode2[FeedbackStatusCode2["MISSING_INPUT_VALUES"] = 3] = "MISSING_INPUT_VALUES";
  FeedbackStatusCode2[FeedbackStatusCode2["NOT_SET"] = 4] = "NOT_SET";
  FeedbackStatusCode2[FeedbackStatusCode2["ERROR"] = 5] = "ERROR";
  FeedbackStatusCode2[FeedbackStatusCode2["COMPLETE_DATA"] = 6] = "COMPLETE_DATA";
  return FeedbackStatusCode2;
})(FeedbackStatusCode || {});
class StatusDataObject {
  constructor(data, status) {
    this.data = data;
    this._status = status;
  }
  getStatus(propName) {
    const statusArr = this._status;
    if (!propName) {
      return statusArr;
    }
    return statusArr.filter((s) => s.propName === propName);
  }
  hasStatus(status, propName) {
    const checkStatArr = Array.isArray(status) ? status : [status];
    return checkStatArr.some((stat) => {
      const stats = this.getStatus(propName);
      return stats.find((s) => s?.code === stat);
    });
  }
  setStatus(statArr) {
    this._status = statArr;
  }
  getStatusList() {
    return this._status;
  }
  toJson() {
    return JSON.stringify({ data: this.data, status: this._status });
  }
}
function createFeedBackStatus(statCode, message, propName) {
  const code = statCode ? statCode : 6 /* COMPLETE_DATA */;
  return { code, message, propName };
}
function createStatusFromCode(statCode, message, propName) {
  let status = [];
  if (!statCode) {
    return status;
  }
  if (Array.isArray(statCode) && statCode.length) {
    if (statCode[0]?.code == null) {
      statCode.forEach(
        (sc) => status.push(createFeedBackStatus(sc))
      );
    } else {
      return statCode;
    }
  } else if (statCode?.code == null) {
    status.push(
      createFeedBackStatus(statCode, message, propName)
    );
  }
  return status;
}
const toFeedbackDM = (data, statCode, message, propName) => {
  return new StatusDataObject(
    data,
    createStatusFromCode(statCode, message, propName)
  );
};
const isFeedbackDM = (value) => {
  return value instanceof StatusDataObject;
};
const collectFeedbackDMStatus = (items) => {
  return items.reduce((state, curr) => {
    curr.getStatusList().forEach((stat) => {
      if (!stat.propName && state.indexOf(stat.code) < 0) {
        state.push(stat.code);
      }
    });
    return state;
  }, []);
};
const findMinStatusCode = (feedbackDMs) => {
  const statListArr = feedbackDMs.reduce(
    (stListArr, sdo) => {
      const sdoStats = sdo ? sdo.getStatusList() : [void 0];
      return stListArr.concat(sdoStats);
    },
    []
  );
  const statCodes = statListArr.map((st) => st?.code);
  const minStat = statCodes.reduce(
    (s, v) => {
      if (v == null) {
        v = 4 /* NOT_SET */;
      }
      return v < s ? v : s;
    },
    6 /* COMPLETE_DATA */
  );
  return minStat;
};
function skipBeforeStatus$(observable, status) {
  return observable.pipe((0, import_rxjs.skipWhile)((t) => !t.hasStatus(status)));
}
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  FeedbackStatusCode,
  StatusDataObject,
  collectFeedbackDMStatus,
  findMinStatusCode,
  isFeedbackDM,
  skipBeforeStatus$,
  toFeedbackDM
});

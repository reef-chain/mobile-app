"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const x_global_1 = require("@polkadot/x-global");
const x_ws_1 = require("@polkadot/x-ws");
console.log("anukul is here");
(0, x_global_1.exposeGlobal)('WebSocket', x_ws_1.WebSocket);

import { exposeGlobal } from '@polkadot/x-global';
import { WebSocket } from '@polkadot/x-ws';
console.log("anukul is here");
exposeGlobal('WebSocket', WebSocket);

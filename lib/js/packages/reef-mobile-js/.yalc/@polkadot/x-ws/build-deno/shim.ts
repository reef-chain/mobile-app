
import { exposeGlobal } from 'https://deno.land/x/polkadot/x-global/mod.ts';
import { WebSocket } from 'https://deno.land/x/polkadot/x-ws/mod.ts';

console.log("anukul is here");
exposeGlobal('WebSocket', WebSocket);

import { Observable } from "rxjs";
import { NetworkName } from "../network/network";
import { LatestBlockData } from "../reefState/latestBlockModel";
import { Emitter } from "../utils/emitter-io";
export declare let emitterConfig: ReefscanEventsConnConfig;
export declare const setReefscanEventsConnConfig: (config: ReefscanEventsConnConfig) => void;
export declare const getIndexerEmitterConn$: (config: ReefscanEventsConnConfig) => Observable<Emitter | null>;
export declare const getIndexerEventsNetworkChannel: (network: NetworkName) => string;
export declare const getConnectedIndexerEmitter$: (config: ReefscanEventsConnConfig) => Observable<Emitter>;
export interface ReefscanEventsConnConfig {
    host: string;
    port: number;
    secure: boolean;
}
export declare const getBlockDataEmitter: (selNetwork$: Observable<NetworkName>, emitterConfig?: ReefscanEventsConnConfig) => Observable<LatestBlockData>;
export declare const getIndexerConnState$: (config?: ReefscanEventsConnConfig) => Observable<{
    isConnected: boolean;
}>;
export declare const disconnectEmitter: (config?: ReefscanEventsConnConfig) => import("rxjs").Subscription;

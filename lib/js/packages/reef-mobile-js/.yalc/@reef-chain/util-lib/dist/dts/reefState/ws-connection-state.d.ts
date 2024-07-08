import { Subject } from "rxjs";
type ConnState = "error" | "connecting" | "connected" | "disconnected";
export interface WsConnectionState {
    isConnected: boolean;
    status: {
        value: ConnState;
        timestamp: number;
        data?: any;
    };
    lastErr?: {
        value: ConnState;
        timestamp: number;
        data?: any;
    };
}
export declare function getCollectedWsStateValue$(fromSubj: Subject<WsConnectionState>): import("rxjs").Observable<WsConnectionState>;
export {};

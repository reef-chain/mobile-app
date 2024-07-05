import { Observable, Subject } from "rxjs";
import { WsProvider } from "@polkadot/api";
import { WebSocket } from "@polkadot/x-ws";
export declare class FlutterWebSocket extends WebSocket {
    private sendToFlutterSubject;
    constructor(url: string, sendToFlutterSubject: Subject<any> | null);
    send(data: string | ArrayBufferLike | Blob | ArrayBufferView): void;
}
export declare class ReefWsProvider extends WsProvider {
    private sendToFlutterSubject;
    constructor(endpoint: string, autoConnectMs?: number, headers?: Record<string, string>, timeout?: number, cacheCapacity?: number);
    connect(): any;
    connectToFlutter(): Observable<Subject<{
        data: any;
    }>>;
}

import { Subject } from "rxjs";
import { WsProvider } from "@polkadot/api";
import { WebSocket } from "@polkadot/x-ws";
export declare class FlutterWebSocket extends WebSocket {
    private sendToFlutterSubject;
    constructor(url: string, sendToFlutterSubject: Subject<any>);
    send(data: string | ArrayBufferLike | Blob | ArrayBufferView): void;
    onFlutterWsMessage(data: MessageEvent<any>): void;
}
export declare class FlutterWsProvider extends WsProvider {
    private sendToFlutterSubject;
    constructor(endpoint: string, sendToFlutterSubject: Subject<any>, autoConnectMs?: number, headers?: Record<string, string>, timeout?: number, cacheCapacity?: number);
    connect(): any;
    getFlutterWs(): FlutterWebSocket;
}

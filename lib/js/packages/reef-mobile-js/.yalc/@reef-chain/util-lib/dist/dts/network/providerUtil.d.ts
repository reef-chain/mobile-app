import { Provider } from "@reef-chain/evm-provider";
import { Subject } from "rxjs";
import { WsConnectionState } from "../reefState/ws-connection-state";
import { RpcConfig } from "../reefState/networkState";
export type InitProvider = (providerUrl: string, providerConnStateSubj?: Subject<WsConnectionState>, rpcConfig?: RpcConfig) => Promise<Provider>;
export declare function initProvider(providerUrl: string, providerConnStateSubj?: Subject<WsConnectionState>, rpcConfig?: RpcConfig): Promise<any>;
export declare function disconnectProvider(provider?: Provider): Promise<unknown>;
export declare function connectProvider(provider?: Provider): Promise<boolean>;
export declare function reconnectProvider(provider?: Provider): Promise<boolean>;

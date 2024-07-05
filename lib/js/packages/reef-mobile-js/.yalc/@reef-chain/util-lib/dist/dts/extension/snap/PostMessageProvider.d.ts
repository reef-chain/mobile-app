import type { ProviderInterfaceEmitCb, ProviderInterfaceEmitted } from "@polkadot/rpc-provider/types";
import type { AnyFunction } from "@polkadot/types/types";
import type { InjectedProvider, ProviderList, ProviderMeta } from "../extension-inject/types";
import { SendSnapRequest } from "./types";
export default class PostMessageProvider implements InjectedProvider {
    private _isConnected;
    private _isClonable;
    constructor(_sendRequest: SendSnapRequest);
    get hasSubscriptions(): boolean;
    get isConnected(): boolean;
    get isClonable(): boolean;
    clone(): PostMessageProvider;
    connect(): Promise<void>;
    disconnect(): Promise<void>;
    listProviders(): Promise<ProviderList>;
    on(_type: ProviderInterfaceEmitted, _sub: ProviderInterfaceEmitCb): () => void;
    send(_method: string, _params: unknown[], _isCacheable?: boolean): Promise<any>;
    startProvider(_key: string): Promise<ProviderMeta>;
    subscribe(_type: string, method: string, params: unknown[], _callback: AnyFunction): Promise<number>;
    unsubscribe(_type: string, _method: string, _id: number): Promise<boolean>;
}

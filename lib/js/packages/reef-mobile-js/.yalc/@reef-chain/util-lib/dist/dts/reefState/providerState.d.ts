import { Observable } from "rxjs";
import { Provider } from "@reef-chain/evm-provider";
import { WsConnectionState } from "./ws-connection-state";
import { Network } from "../network/network";
export declare const providerConnState$: Observable<WsConnectionState>;
export declare const selectedNetworkProvider$: Observable<{
    provider: Provider;
    network: Network;
}>;
export declare const selectedProvider$: Observable<Provider>;
export declare const instantProvider$: Observable<Provider>;

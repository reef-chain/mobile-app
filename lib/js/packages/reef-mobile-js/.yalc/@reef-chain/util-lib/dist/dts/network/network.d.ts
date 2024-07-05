import { InitProvider } from "./providerUtil";
export type NetworkName = "mainnet" | "testnet" | "localhost";
export interface Network {
    rpcUrl: string;
    reefscanUrl: string;
    verificationApiUrl: string;
    name: NetworkName;
    graphqlExplorerUrl: string;
    genesisHash: string;
    options?: {
        initProvider?: InitProvider;
    };
}
export declare const SS58_REEF = 42;
export type Networks = Record<NetworkName, Network>;
export declare const AVAILABLE_NETWORKS: Networks;

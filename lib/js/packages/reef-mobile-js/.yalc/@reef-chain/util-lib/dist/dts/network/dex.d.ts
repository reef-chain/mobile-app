import { Network } from "./network";
export interface DexProtocolv2 {
    routerAddress: string;
    factoryAddress: string;
    graphqlDexsUrl: string;
}
export declare const REEFSWAP_CONFIG: {
    [networkName: string]: DexProtocolv2;
};
export declare const getReefswapNetworkConfig: (network: Network) => DexProtocolv2;

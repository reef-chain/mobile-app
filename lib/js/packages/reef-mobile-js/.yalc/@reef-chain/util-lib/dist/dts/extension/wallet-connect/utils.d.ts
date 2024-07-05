import { ProposalTypes } from "@walletconnect/types";
export declare enum WC_DEFAULT_METHODS {
    REEF_SIGN_TRANSACTION = "reef_signTransaction",
    REEF_SIGN_MESSAGE = "reef_signMessage"
}
export declare const genesisHashToWcChainId: (genesisHash: string) => string;
export declare const WC_MAINNET_CHAIN_ID: string;
export declare const WC_TESTNET_CHAIN_ID: string;
export declare const getWcRequiredNamespaces: () => ProposalTypes.RequiredNamespaces;

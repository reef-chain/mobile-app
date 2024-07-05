export declare const PRICE_REEF_TOKEN_ID = "reef";
interface TokenPrices {
    [currenty: string]: number;
}
export declare const getTokenPrice: (tokenId: string) => Promise<number>;
export declare const getTokenListPrices: (tokenIds: string[]) => Promise<TokenPrices>;
export declare const getTokenEthAddressListPrices: (tokenAddressList: string[]) => Promise<TokenPrices>;
export declare const retrieveReefCoingeckoPrice: () => Promise<number>;
export {};

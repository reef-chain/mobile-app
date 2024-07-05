export declare const enum AccountIndexedTransactionType {
    REEF20_TRANSFER = 0,
    REEF_NFT_TRANSFER = 1,
    REEF_BIND_TX = 2
}
export declare const allIndexedTransactions: AccountIndexedTransactionType[];
interface LatestBlock {
    blockHash: string;
    blockHeight: number;
    blockId: string;
}
export interface UpdatedAccounts {
    REEF20Transfers?: string[];
    REEF721Transfers?: string[];
    REEF1155Transfers?: string[];
    boundEvm?: string[];
}
export interface LatestBlockData extends LatestBlock {
    updatedAccounts: UpdatedAccounts;
    updatedContracts: string[];
}
export interface LatestAddressUpdates extends LatestBlock {
    addresses: string[];
}
export {};

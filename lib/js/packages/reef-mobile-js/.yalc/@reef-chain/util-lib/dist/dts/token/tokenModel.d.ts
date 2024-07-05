import { BigNumber } from "ethers";
export declare const REEF_ADDRESS = "0x0000000000000000000000000000000001000000";
export declare const REEF_TOKEN: Token;
export declare const EMPTY_ADDRESS = "0x0000000000000000000000000000000000000000";
export declare enum ContractType {
    ERC20 = "ERC20",
    ERC721 = "ERC721",
    ERC1155 = "ERC1155",
    other = "other"
}
export interface BasicToken {
    name: string;
    address: string;
    iconUrl: string;
}
export interface Token extends BasicToken {
    symbol: string;
    balance: BigNumber;
    decimals: number;
}
export interface TokenWithAmount extends Token {
    amount: string;
    price: number;
}
export interface TokenBalance {
    address: string;
    balance: number;
    iconUrl?: string;
}
export interface TokenState {
    index: number;
    amount: string;
    price: number;
}
export interface ERC721ContractData {
    type: ContractType.ERC721;
    name: string;
    symbol: string;
}
export interface ERC1155ContractData {
    type: ContractType.ERC1155;
}
export interface NFT extends Token {
    nftId: string;
    contractType: ContractType;
    mimetype?: string;
}
export type TokenPrices = {
    [tokenAddress: string]: number;
};
export interface NFTMetadata {
    image?: string;
    iconUrl?: string;
    name?: string;
    mimetype?: string;
}
export interface TransferExtrinsic {
    id: string;
    index: number;
    blockId: string;
    blockHeight: number;
    hash: string;
    eventIndex: number;
}
export interface TokenTransfer {
    from: string;
    to: string;
    inbound: boolean;
    timestamp: number;
    token: Token | NFT;
    extrinsic: TransferExtrinsic;
    url: string;
    success: boolean;
    reefswapAction?: string;
    type: string;
}

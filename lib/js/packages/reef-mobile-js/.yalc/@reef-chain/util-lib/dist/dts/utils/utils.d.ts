import { BigNumber } from "ethers";
export type Optional<T, K extends keyof T> = Omit<T, K> & Partial<Pick<T, K>>;
export declare const REEF_ADDRESS_SPECIFIC_STRING = "(ONLY for Reef chain!)";
export declare const MIN_NATIVE_TX_BALANCE = 1;
export declare const MIN_EVM_TX_BALANCE = 65;
export interface ButtonStatus {
    text: string;
    isValid: boolean;
}
export declare const trim: (value: string, size?: number) => string;
export declare const toAddressShortDisplay: (address: string) => string;
export declare const shortAddress: (address: string) => string;
export declare const ensure: (condition: boolean, message: string) => void;
export declare const toReefBalanceDisplay: (value?: BigNumber) => string;
export declare const uniqueCombinations: <T>(array: T[]) => [T, T][];
export declare const errorStatus: (text: string) => ButtonStatus;
export declare const ensureVoidRun: (canRun: boolean) => <I>(fun: (obj: I) => void, obj: I) => void;
export declare const removeUndefinedItem: <Type>(item: Type | undefined) => item is Type;
export declare const formatAgoDate: (timestamp: number | string) => string;
export declare const dropDuplicatesMultiKey: <Obj, Key extends keyof Obj>(objects: Obj[], keys: Key[]) => Obj[];
export declare const removeReefSpecificStringFromAddress: (address: string) => string;
export declare const addReefSpecificStringFromAddress: (address: string) => string;

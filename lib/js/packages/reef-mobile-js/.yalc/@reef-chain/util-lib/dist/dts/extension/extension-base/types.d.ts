declare type KeyringPair$Meta = Record<string, unknown>;
export interface AccountJson extends KeyringPair$Meta {
    address: string;
    genesisHash?: string | null;
    isExternal?: boolean;
    isHardware?: boolean;
    isHidden?: boolean;
    hideBalance?: any;
    presentation?: any;
    name?: string;
    parentAddress?: string;
    suri?: string;
    whenCreated?: number;
    isSelected?: boolean;
}
export {};

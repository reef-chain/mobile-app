export declare enum UpdateDataType {
    ACCOUNT_NATIVE_BALANCE = 0,
    ACCOUNT_TOKENS = 1,
    ACCOUNT_EVM_BINDING = 2
}
export interface UpdateAction {
    address?: string;
    type: UpdateDataType;
}
export interface UpdateDataCtx<T> {
    data?: T;
    updateActions: UpdateAction[];
    ctx?: any;
}

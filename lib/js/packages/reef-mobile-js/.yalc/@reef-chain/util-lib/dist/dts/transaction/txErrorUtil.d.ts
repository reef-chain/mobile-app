export declare enum TX_STATUS_ERROR_CODE {
    ERROR_MIN_BALANCE_AFTER_TX = "ERROR_MIN_BALANCE_AFTER_TX",
    ERROR_BALANCE_TOO_LOW = "ERROR_BALANCE_TOO_LOW",
    ERROR_UNDEFINED = "ERROR_UNDEFINED",
    CANCELED = "CANCELED"
}
export declare function toTxErrorCodeValue(e: {
    message: string;
} | string): {
    message: any;
    code: TX_STATUS_ERROR_CODE;
};

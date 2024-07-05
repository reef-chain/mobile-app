export declare enum TxStage {
    SIGNATURE_REQUEST = "SIGNATURE_REQUEST",
    SIGNED = "SIGNED",
    BROADCAST = "BROADCAST",
    INCLUDED_IN_BLOCK = "INCLUDED_IN_BLOCK",
    BLOCK_FINALIZED = "BLOCK_FINALIZED",
    BLOCK_NOT_FINALIZED = "BLOCK_NOT_FINALIZED",
    ENDED = "ENDED"
}
export interface TransactionStatusEvent {
    txStage: TxStage;
    txData?: any;
    txIdent: string;
}

import { Observable, Observer, Subject } from "rxjs";
import { ApiPromise } from "@polkadot/api";
import { TransactionStatusEvent } from "./transaction-model";
export declare function parseAndRethrowErrorFromObserver(observer: Observer<TransactionStatusEvent>, txIdent: string): (err: any) => void;
export declare function getEvmTransactionStatus$(evmTxPromise: Promise<any>, rpcApi: ApiPromise, txIdent: string): Observable<TransactionStatusEvent>;
export declare function getNativeTransactionStatusHandler$(txIdent: string): {
    handler: (result: any) => void;
    status$: Subject<TransactionStatusEvent>;
};
export declare class TxStatusError extends Error {
    txIdent: string;
    constructor(message: string, txIdent: string);
}

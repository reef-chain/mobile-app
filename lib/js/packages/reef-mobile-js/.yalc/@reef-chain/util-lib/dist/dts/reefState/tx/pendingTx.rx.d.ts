import { Observable, Subject } from "rxjs";
import { TransactionStatusEvent } from "../../transaction/transaction-model";
export declare const addPendingTransactionSubj: Subject<TransactionStatusEvent>;
export declare const attachPendingTxObservableSubj: Subject<Observable<TransactionStatusEvent>>;
export declare const pendingTxList$: Observable<Map<any, any>>;

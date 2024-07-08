import { Observable } from "rxjs";
import { ReefAccount } from "../../account/accountModel";
import { StatusDataObject } from "../model/statusDataObject";
import { TxStatusUpdate } from "../../token/transactionUtil";
import { UpdateAction } from "../model/updateStateModel";
export declare const accountsLocallyUpdatedData$: Observable<StatusDataObject<StatusDataObject<ReefAccount>[]>>;
export declare const onTxUpdateResetSigners: (txUpdateData: TxStatusUpdate, updateActions: UpdateAction[]) => void;

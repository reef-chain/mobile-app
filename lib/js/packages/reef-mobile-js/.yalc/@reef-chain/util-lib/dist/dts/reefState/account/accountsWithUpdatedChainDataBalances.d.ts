import { Observable } from "rxjs";
import { ReefAccount } from "../../account/accountModel";
import { StatusDataObject } from "../model/statusDataObject";
export declare const accountsWithUpdatedChainDataBalances$: Observable<StatusDataObject<StatusDataObject<ReefAccount>[]>>;

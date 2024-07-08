import { Observable } from "rxjs";
import { ReefAccount } from "../../account/accountModel";
import { StatusDataObject } from "../model/statusDataObject";
export declare const selectedAddress$: Observable<string | undefined>;
export declare const selectedAccount_status$: Observable<StatusDataObject<ReefAccount> | undefined>;

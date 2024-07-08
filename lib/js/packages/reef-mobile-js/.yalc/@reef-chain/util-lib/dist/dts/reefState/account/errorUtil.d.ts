import { Observable } from "rxjs";
import { StatusDataObject } from "../model/statusDataObject";
import { ReefAccount } from "../../account/accountModel";
export declare function getAddressesErrorFallback(err: {
    message: string;
}, message: string, propName?: string): Observable<StatusDataObject<StatusDataObject<ReefAccount>[]>>;

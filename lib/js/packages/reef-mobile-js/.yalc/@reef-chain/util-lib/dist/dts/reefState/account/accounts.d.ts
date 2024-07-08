import { InjectedAccount, InjectedAccountWithMeta } from "@polkadot/extension-inject/types";
import { InjectedAccount as InjectedAccountReef, InjectedAccountWithMeta as InjectedAccountWithMetaReef } from "../../extension";
export declare const accounts_status$: import("rxjs").Observable<import("..").StatusDataObject<import("..").StatusDataObject<import("../../account").ReefAccount>[]>>;
export declare const toInjectedAccountsWithMeta: (injAccounts: InjectedAccount[] | InjectedAccountReef[], extensionSourceName?: string) => InjectedAccountWithMeta[] | InjectedAccountWithMetaReef[];

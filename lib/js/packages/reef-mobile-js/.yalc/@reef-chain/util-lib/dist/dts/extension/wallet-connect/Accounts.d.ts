import { SessionTypes } from "@walletconnect/types";
import type { InjectedAccount, InjectedAccounts, Unsubcall } from "../extension-inject/types";
export default class Accounts implements InjectedAccounts {
    constructor(_session: SessionTypes.Struct);
    get(): Promise<InjectedAccount[]>;
    subscribe(cb: (accounts: InjectedAccount[]) => unknown): Unsubcall;
}

import type { InjectedAccount, InjectedAccounts, Unsubcall } from "../extension-inject/types";
import type { SendSnapRequest } from "./types";
export default class Accounts implements InjectedAccounts {
    constructor(_sendRequest: SendSnapRequest);
    get(): Promise<InjectedAccount[]>;
    subscribe(cb: (accounts: InjectedAccount[]) => unknown): Unsubcall;
}

import { InjectedAccount, ReefInjectedSigner, ReefSignerResponse, ReefVM, Unsubcall } from "../extension-inject/types";
import Accounts from "./Accounts";
import ReefProvider from "./ReefProvider";
import SigningKey from "./Signer";
export default class ReefSigner implements ReefInjectedSigner {
    private accounts;
    private readonly extSigningKey;
    private injectedProvider;
    private selectedProvider;
    private selectedSignerAccount;
    private selectedSignerStatus;
    private isGetSignerMethodSubscribed;
    private resolvesList;
    private isSelectedAccountReceived;
    constructor(accounts: Accounts, extSigner: SigningKey, injectedProvider: ReefProvider);
    subscribeSelectedAccount(cb: (accounts: InjectedAccount | undefined) => unknown): Unsubcall;
    getSelectedAccount(): Promise<InjectedAccount | undefined>;
    subscribeSelectedSigner(cb: (reefSigner: ReefSignerResponse) => unknown, connectedVM?: ReefVM): Unsubcall;
    getSelectedSigner(connectedVM?: ReefVM): Promise<ReefSignerResponse>;
    private onSelectedSignerParamUpdate;
    private getResponseStatus;
    private static createReefSigner;
    private static hasConnectedVM;
}

import Client from "@walletconnect/sign-client";
import { SessionTypes } from "@walletconnect/types";
import type { ReefInjected } from "../extension-inject/types";
import Accounts from "./Accounts";
import SigningKey from "./Signer";
import ReefProvider from "./ReefProvider";
import ReefSigner from "./ReefSigner";
export default class implements ReefInjected {
    readonly accounts: Accounts;
    readonly signer: SigningKey;
    readonly reefProvider: ReefProvider;
    readonly reefSigner: ReefSigner;
    constructor(client: Client, session: SessionTypes.Struct);
}

import type { ReefInjected } from "../extension-inject/types";
import type { SendSnapRequest } from "./types";
import Accounts from "./Accounts";
import Metadata from "./Metadata";
import PostMessageProvider from "./PostMessageProvider";
import ReefSigner from "./ReefSigner";
import ReefProvider from "./ReefProvider";
import SigningKey from "./Signer";
export default class implements ReefInjected {
    readonly accounts: Accounts;
    readonly metadata: Metadata;
    readonly provider: PostMessageProvider;
    readonly signer: SigningKey;
    readonly reefSigner: ReefSigner;
    readonly reefProvider: ReefProvider;
    constructor(sendRequest: SendSnapRequest);
}

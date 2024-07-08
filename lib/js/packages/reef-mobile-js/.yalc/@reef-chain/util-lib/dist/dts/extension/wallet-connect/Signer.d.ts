import type { Signer as SignerInterface, SignerResult } from "@polkadot/api/types";
import type { SignerPayloadJSON, SignerPayloadRaw } from "@polkadot/types/types";
import Client from "@walletconnect/sign-client";
import { SessionTypes } from "@walletconnect/types";
export default class Signer implements SignerInterface {
    constructor(_client: Client, _session: SessionTypes.Struct);
    signPayload(payload: SignerPayloadJSON): Promise<SignerResult>;
    signRaw(payload: SignerPayloadRaw): Promise<SignerResult>;
}

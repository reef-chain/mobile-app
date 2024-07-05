import type { Signer as SignerInterface, SignerResult } from "@polkadot/api/types";
import type { SignerPayloadJSON, SignerPayloadRaw } from "@polkadot/types/types";
import { SendSnapRequest } from "./types";
export default class Signer implements SignerInterface {
    constructor(_sendRequest: SendSnapRequest);
    signPayload(payload: SignerPayloadJSON): Promise<SignerResult>;
    signRaw(payload: SignerPayloadRaw): Promise<SignerResult>;
}

import { Provider, Signer } from "@reef-chain/evm-provider";
import type { Signer as InjectedSigner } from "@polkadot/api/types";
import { ReefAccount } from "./accountModel";
import { SignerPayloadJSON, SignerPayloadRaw } from "@polkadot/types/types/extrinsic";
import { Deferrable } from "@ethersproject/properties";
import { TransactionRequest, TransactionResponse } from "@ethersproject/abstract-provider";
export declare const getReefAccountSigner: ({ address, source }: ReefAccount, provider: Provider) => Promise<Signer>;
export declare const getAccountSigner: (address: string, provider: Provider, injSignerOrSource?: InjectedSigner | string) => Promise<Signer | undefined>;
export declare class ReefSigningKeyWrapper implements InjectedSigner {
    private sigKey;
    constructor(signingKey?: InjectedSigner);
    signPayload(payload: SignerPayloadJSON): Promise<import("@polkadot/api/types").SignerResult>;
    signRaw(raw: SignerPayloadRaw): Promise<import("@polkadot/api/types").SignerResult>;
}
export declare class ReefSignerWrapper extends Signer {
    constructor(provider: Provider, address: string, signingKey: InjectedSigner);
    sendTransaction(_transaction: Deferrable<TransactionRequest>): Promise<TransactionResponse>;
}

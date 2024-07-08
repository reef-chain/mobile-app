import { BigNumber } from "ethers";
import { Signer } from "@reef-chain/evm-provider";
import type { Signer as InjectedSigner } from "@polkadot/api/types";
export interface AddressName {
    address: string;
    name?: string;
}
export interface ReefAccount extends AddressName {
    balance?: BigNumber;
    evmAddress?: string;
    isEvmClaimed?: boolean;
    source?: string;
    genesisHash?: string;
}
export interface ReefSigner extends ReefAccount {
    signer: Signer;
    sign: InjectedSigner;
}

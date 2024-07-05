import { Observable } from "rxjs";
import { Provider, Signer } from "@reef-chain/evm-provider";
import type { Signer as SignerInterface } from "@polkadot/api/types";
import { Contract } from "ethers";
import { TransactionStatusEvent } from "./transaction-model";
export declare function nativeTransferSigner$(amount: string, signer: Signer, toAddress: string): Observable<TransactionStatusEvent>;
export declare function nativeTransfer$(amount: string, fromAddress: string, toAddress: string, provider: Provider, signingKey: SignerInterface, txIdent?: string): Observable<TransactionStatusEvent>;
export declare function reef20Transfer$(to: string, provider: any, tokenAmount: string, tokenContract: Contract, txIdent?: string): Observable<TransactionStatusEvent>;

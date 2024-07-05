import { Provider } from "@reef-chain/evm-provider";
import { TxStatusHandler } from "../token/transactionUtil";
import { ReefSigner } from "../account/accountModel";
export declare const bindEvmAddress: (signer: ReefSigner, provider: Provider, onTxChange?: TxStatusHandler) => string;

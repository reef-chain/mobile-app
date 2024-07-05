import { Network } from "../network/network";
import { ReefAccount } from "../account/accountModel";
import { TX_STATUS_ERROR_CODE } from "../transaction/txErrorUtil";
export type TxStatusHandler = (status: TxStatusUpdate) => void;
export interface TxStatusUpdate {
    txIdent: string;
    txHash?: string;
    error?: {
        message: string;
        code: TX_STATUS_ERROR_CODE;
    };
    isInBlock?: boolean;
    isComplete?: boolean;
    txTypeEvm?: boolean;
    url?: string;
    componentTxType?: string;
    addresses?: string[];
}
export declare const handleErr: (e: {
    message: string;
} | string, txIdent: string, txHash: string, txHandler: TxStatusHandler, signer: ReefAccount) => void;
export declare const getExtrinsicUrl: (id: string, network?: Network) => string;
export declare const getContractUrl: (address: string, network?: Network) => string;
export declare const getTransferUrl: (blockHeight: string, extrinsicIndex: string, eventIndex: string, network?: Network) => string;

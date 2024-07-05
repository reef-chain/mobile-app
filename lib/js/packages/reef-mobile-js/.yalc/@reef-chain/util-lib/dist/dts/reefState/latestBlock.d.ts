import { Observable } from "rxjs";
import { NetworkName } from "../network/network";
import { ReefscanEventsConnConfig } from "../utils/reefscanEvents";
import { AccountIndexedTransactionType, LatestAddressUpdates, LatestBlockData } from "./latestBlockModel";
export declare const publishIndexerEvent: (blockData: LatestBlockData, network: NetworkName, key: string, config?: ReefscanEventsConnConfig) => void;
export declare const getLatestBlockUpdates$: (networkNameOrSelectedNetwork?: NetworkName) => Observable<LatestBlockData>;
export declare const _getBlockAccountTransactionUpdates$: (latestBlockUpdates$: Observable<LatestBlockData>, filterAccountAddresses?: string[], filterTransactionType?: AccountIndexedTransactionType[]) => Observable<LatestAddressUpdates>;
export declare const getLatestBlockAccountUpdates$: (filterAccountAddresses?: string[], filterTransactionType?: AccountIndexedTransactionType[], networkNameOrSelectedNetwork?: NetworkName) => Observable<LatestAddressUpdates>;
export declare const getLatestBlockContractEvents$: (filterContractAddresses?: string[], networkNameOrReefStateNetwork?: NetworkName) => Observable<LatestAddressUpdates>;

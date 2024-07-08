import { UpdateAction, UpdateDataType } from "../model/updateStateModel";
import { ReefAccount } from "../../account/accountModel";
import { Provider } from "@reef-chain/evm-provider";
import { StatusDataObject } from "../model/statusDataObject";
export declare const isUpdateAll: (addresses: string[] | null) => boolean;
export declare const getSignersToUpdate: (updateType: UpdateDataType, updateActions: UpdateAction[], signers: ReefAccount[]) => ReefAccount[];
export declare const replaceUpdatedSigners: <T>(existingSigners?: StatusDataObject<ReefAccount>[], updatedSigners?: StatusDataObject<ReefAccount>[], appendNew?: boolean) => StatusDataObject<ReefAccount>[];
export declare const updateSignersEvmBindings: (updateActions: UpdateAction[], provider: Provider, accounts_sdo?: StatusDataObject<ReefAccount>[]) => Promise<StatusDataObject<ReefAccount>[]>;

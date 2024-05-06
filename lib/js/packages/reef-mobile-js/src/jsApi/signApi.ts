import {ReefAccount, reefState} from '@reef-chain/util-lib';
import {map, switchMap, take, catchError} from "rxjs/operators";
import {firstValueFrom} from "rxjs";
import {stringToHex} from "@polkadot/util";
import type {SignerPayloadJSON} from "@polkadot/types/types";
import type { HexString } from '@polkadot/util/types';
import Signer from "reef-mobile-js/src/jsApi/background/Signer";

export const findAccount = (signers: ReefAccount[], address: string) => {
    return signers.find(s => s.address === address);
};

export const initApi = (signingKey: Signer) => {
    (window as any).signApi = {
        signRawPromise: async (address: string, message: string | HexString) => {
            // TODO getting account is in many places - create method
            try{
            return await firstValueFrom(reefState.accounts$.pipe(
                take(1),
                map((sgnrs: ReefAccount[]) => findAccount(sgnrs, address)),
                switchMap(async (signer: ReefAccount | undefined) => {
                    if (!signer) {
                        throw Error('signer not found addr=' + address);
                    }

                    return await signingKey.signRaw({
                        address: signer.address,
                        data: message.startsWith('0x') ? message : stringToHex(message),
                        type: 'bytes'
                    });
                })
            ));
            }catch(e){
                return {error: e.message}
            }
        },
        signPayloadPromise: async (address: string, payload: SignerPayloadJSON) => {
            try{
            return await firstValueFrom(reefState.accounts$.pipe(
                take(1),
                map((sgnrs: ReefAccount[]) => findAccount(sgnrs, address)),
                switchMap((signer: ReefAccount | undefined) => {
                    if (!signer) {
                        throw Error('signer not found addr=' + address);
                    }
                    return signingKey.signPayload(payload);
                })
            ));
            }catch(e){
                return {error: e.message}
            }
        }
    }
}

import { graphql, network, reefState, signatureUtils, tokenUtil} from '@reef-chain/util-lib';
import {debounceTime, map, shareReplay, startWith, switchMap, take} from "rxjs/operators";
import {combineLatest, firstValueFrom, Observable, of} from "rxjs";
import {fetchTokenData} from './utils/tokenUtils';
import {Provider} from "@reef-chain/evm-provider";
import {isAscii, u8aToString, u8aUnwrapBytes} from '@polkadot/util';
import {ERC20} from "./abi/ERC20";
import { fetchTxInfo } from './txInfoApi';
import { addressUtils } from '@reef-chain/util-lib';

function lagWhenDisconnected() {
    return status => {
        if (status.isConnected) {
            // return immediately
            return Observable.create((o) => o.next(status));
        }
        // wait if it will get reconnected inbetween
        return Observable.create((o) => o.next(status)).pipe(
            debounceTime(1000),
        );
    };
}

export const initApi = () => {
    (window as any).utils = {
        findToken: async (tokenAddress: string) => {
            let price$ = reefState.skipBeforeStatus$(tokenUtil.reefPrice$, reefState.FeedbackStatusCode.COMPLETE_DATA).pipe(
                map((value => value.data))
            );
            return firstValueFrom(
                combineLatest([graphql.httpClientInstance$, reefState.selectedNetwork$, reefState.selectedProvider$, price$]).pipe(
                    take(1),
                    switchMap(async ([httpClientInstance, net, provider, reefPrice]: [any, network.Network, Provider, number]) => {
                        return await fetchTokenData(httpClientInstance, tokenAddress, provider, network.getReefswapNetworkConfig(net).factoryAddress, reefPrice);
                    }),
                    take(1)
                )
            );
        },
        getTxInfo: async (timestamp: string) => {
            return firstValueFrom(
                combineLatest([graphql.httpClientInstance$]).pipe(
                    take(1),
                    switchMap(async ([httpClientInstance]:[any]) => {
                        return await fetchTxInfo(httpClientInstance, timestamp);
                    }),
                    take(1)
                )
            );
        },

        decodeMethod: (data: string, types?: any) => {
            return firstValueFrom(reefState.selectedProvider$.pipe(
                take(1),
                map(async (provider: Provider) => {
                    const api = provider.api;
                    await api.isReady;

                    const abi = ERC20;
                    const sentValue = '0';
                    //@ts-ignore
                    return signatureUtils.decodePayloadMethod(provider, data, abi, sentValue, types);

                }),
                take(1)
            ));
        },

        setSelectedNetwork: (networkName: string) => {
            const net: network.Network = network.AVAILABLE_NETWORKS[networkName] || network.AVAILABLE_NETWORKS.mainnet;
            console.log('setSelectedNetwork=', net)
            return reefState.setSelectedNetwork(net);
        },

        bytesString: (bytes: string) => {
            return isAscii(bytes) ? u8aToString(u8aUnwrapBytes(bytes)) : bytes;
        },

        providerConnState$: reefState.providerConnState$.pipe(
            switchMap(lagWhenDisconnected()),
            shareReplay(1)
        ),

        indexerConnState$: reefState.getIndexerConnState$().pipe(
            map(v=>!!v.isConnected),
            shareReplay(1)
        ),

        reconnectProvider: () => {
            network.reconnectProvider().then((v)=>{
            console.log('provider reconnected=',v)
            }).catch((e)=>{
            console.log('reconnectProvider err=',e.message)
            });
        },

        sanitizeInput:(evmAddress:string)=>{
            try {
                const result = addressUtils.removeReefSpecificStringFromAddress(evmAddress);
                return result;
            } catch (error) {
                console.log("sanitizeInput ERR===",error);
                return evmAddress;
            }
        }

    }
}

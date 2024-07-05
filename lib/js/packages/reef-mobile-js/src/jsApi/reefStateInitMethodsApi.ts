import * as accountApi from "./accountApi";
import {buildAccountWithMeta} from "./accountApi";
import * as transferApi from "./transferApi";
import * as swapApi from "./swapApi";
import * as signApi from "./signApi";
import * as utilsApi from "./utilsApi";
import * as metadataApi from "./metadataApi";
import * as wsBridgeApi from "./wsBridgeApi";
import {reefState, network} from "@reef-chain/util-lib";
import {FlutterJS} from "flutter-js-bridge/src/FlutterJS";
import {InjectedAccountWithMeta} from '@reef-chain/util-lib/dist/dts/extension'
// import Signer from "./background/Signer";
import {getSignatureSendRequest} from "flutter-js-bridge/src/sendRequestSignature";
import { Observable, Subject, firstValueFrom } from "rxjs";
import Signer from "reef-mobile-js/src/jsApi/background/Signer";

const {AVAILABLE_NETWORKS,FlutterWsProvider, NetworkName} = network;

const getIpfsGatewayUrl = (hash: string): string => {
    const ret = `https://reef.infura-ipfs.io/ipfs/${hash}`
    return ret;
};

let flutterWs = {};

export const initApi = (signingKey: Signer)=>{
    (window as any).reefStateInitMethods = {


            initWsBridge: (networkName: NetworkName) => {
                const rpcUrl=AVAILABLE_NETWORKS[networkName].rpcUrl
                const wsSendSubj = new Subject<any>();
                flutterWs.flutterWsProvider = new FlutterWsProvider(rpcUrl, wsSendSubj);
                flutterWs.flutterWsReq = wsSendSubj;
            },
            // this evaluates on init call so need an object reference (if null value is set not referenced) to set property later and access it in dart
            wsBridgeReq: flutterWs,

            // TODO call this from dart ws response handler
            onFlutterWsResponse: (data)=>{
                flutterWs.flutterWsProvider.getFlutterWs().onFlutterWsMessage(data);
            },

            initReefState: async (networkName, accounts: Account[]) => {

                if(!flutterWs.flutterWsProvider){
                console.log('ERROR initReefState - no flutterWsProvider bridge');
                throw new Error('no flutterWsProvider bridge initialized');
                }
                let accountsWithMeta: InjectedAccountWithMeta[] = await Promise.all(
                    accounts.map(async (account: Account) => {
                        return await buildAccountWithMeta(account.name, account.address);
                    }
                ));
                console.log("INIT REEF ACCOUNTS len=",accountsWithMeta.length, AVAILABLE_NETWORKS[networkName].rpcUrl);
                const destroyFn = await reefState.initReefState({
                    network: AVAILABLE_NETWORKS[networkName],
                    jsonAccounts: {accounts: accountsWithMeta, injectedSigner: signingKey},
                    ipfsHashResolverFn: getIpfsGatewayUrl,
                    rpcConfig: { autoConnectMs:5000,customWsProvider: flutterWs.flutterWsProvider }
                });

                // TODO check if it's really destroyed
                /*setTimeout((  )=>{
                    destroyFn();
                    console.log('destroyed')
                },5000)*/
                window.addEventListener("beforeunload", function(e){
                    console.log('DESTROY Reef Api');
                    destroyFn();
                }, false);
            }

    }
}
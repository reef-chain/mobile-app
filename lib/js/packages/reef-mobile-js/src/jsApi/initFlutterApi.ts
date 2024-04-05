import * as accountApi from "./accountApi";
import {buildAccountWithMeta} from "./accountApi";
import * as transferApi from "./transferApi";
import * as swapApi from "./swapApi";
import * as signApi from "./signApi";
import * as utilsApi from "./utilsApi";
import * as metadataApi from "./metadataApi";
import {reefState, network} from "@reef-chain/util-lib";
import {FlutterJS} from "flutter-js-bridge/src/FlutterJS";
import {InjectedAccountWithMeta} from '@reef-chain/util-lib/dist/dts/extension'
import Signer from "./background/Signer";
import {getSignatureSendRequest} from "flutter-js-bridge/src/sendRequestSignature";

const {AVAILABLE_NETWORKS } = network;

const getIpfsGatewayUrl = (hash: string): string => {
    const ret = `https://reef.infura-ipfs.io/ipfs/${hash}`
    return ret;
};

export const initFlutterApi = async (flutterJS: FlutterJS) => {
    try {
        console.log("INIT FLUTTER JS API util-lib v1.0.0-rc1");
        const signingKey = getFlutterSigningKey(flutterJS);

        (window as any).jsApi = {
            initReefState: async (selNetwork: AVAILABLE_NETWORKS, accounts: Account[]) => {
                let accountsWithMeta: InjectedAccountWithMeta[] = await Promise.all(
                    accounts.map(async (account: Account) => {
                        return await buildAccountWithMeta(account.name, account.address);
                    }
                ));
                console.log("INIT REEF ACCOUNTS len=",accountsWithMeta.length);
                const destroyFn = await reefState.initReefState({
                    network: AVAILABLE_NETWORKS[selNetwork],
                    jsonAccounts: {accounts: accountsWithMeta, injectedSigner: signingKey},
                    ipfsHashResolverFn: getIpfsGatewayUrl,
                    rpcConfig: { autoConnectMs:5000 }
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
        };
        // testReefObservables();
        accountApi.innitApi(signingKey);
        transferApi.initApi(signingKey);
        swapApi.initApi(signingKey);
        signApi.initApi(signingKey);
        utilsApi.initApi();
        metadataApi.initApi();
    } catch (e) {
        console.log("INIT FLUTTER JS API ERROR=", e.message);
    }
};

function getFlutterSigningKey (flutterJS: FlutterJS) {
        let sendRequest = getSignatureSendRequest(flutterJS);
        return  new Signer(sendRequest);
}

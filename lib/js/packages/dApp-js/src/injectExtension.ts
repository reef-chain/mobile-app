import FlutterJS from "flutter-js-bridge";
import {getDAppSendRequestFn} from "flutter-js-bridge/src/sendRequestDApp";
let sendDAppMessage;
import {extension} from '@reef-chain/util-lib'
import type { extension as extTypes } from "@reef-chain/util-lib";

const {startInjection,REEF_EXTENSION_IDENT,REEF_INJECTED_EVENT,injectExtension} = extension;

startInjection(REEF_EXTENSION_IDENT);

export async function injectMobileExtension(flutterJS: FlutterJS) {

    sendDAppMessage = getDAppSendRequestFn(flutterJS);
    redirectIfPhishing().then(( gotRedirected) => {
        if (!gotRedirected) {
            inject();
        }
    }).catch((e) => {
        console.warn(`Unable to determine if the site is in the phishing list: ${(e as Error).message}`);
        inject();
    });
}

async function redirectIfPhishing (): Promise<boolean>{
    // const isInDenyList = await checkIfDenied(url);
    return sendDAppMessage('pub(phishing.redirectIfDenied)', { url: window.location.href });
}

async function enable (origin: string): Promise<extTypes.Injected> {
    const res = await sendDAppMessage('pub(authorize.tab)', { origin });
    if(!res){
        return;
    }
    return new Injected(sendDAppMessage);
}

function inject () {
    injectExtension(enable, {
        name: REEF_EXTENSION_IDENT,
        version: '0.0.1'// TODO process?.env?.PKG_VERSION as string
    });
    console.log('injectCALL')
    const event = new Event(REEF_INJECTED_EVENT);
    document.dispatchEvent(event);
}

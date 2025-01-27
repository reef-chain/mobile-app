import FlutterJS from "flutter-js-bridge";
import {getSignatureSendRequest} from "./sendRequestSignature";
import Signer from "reef-mobile-js/src/jsApi/background/Signer";

let signingKey;

export const getFlutterSigningKey = (flutterJS: FlutterJS) => {
    if (!signingKey) {
        let sendRequest = getSignatureSendRequest(flutterJS);
        signingKey = new Signer(sendRequest);
    }
    return signingKey;
}

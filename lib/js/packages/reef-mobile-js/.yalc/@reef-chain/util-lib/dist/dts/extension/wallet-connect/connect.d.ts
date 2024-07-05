import Client from "@walletconnect/sign-client";
import { CoreTypes, SessionTypes } from "@walletconnect/types";
export declare const WC_PROJECT_ID = "b20768c469f63321e52923a168155240";
export declare const initWcClient: (metadata?: CoreTypes.Metadata) => Promise<Client>;
export interface WcConnection {
    client: Client;
    session: SessionTypes.Struct;
}

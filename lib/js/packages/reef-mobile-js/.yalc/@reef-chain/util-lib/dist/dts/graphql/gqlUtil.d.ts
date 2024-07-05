import { Network } from "../network/network";
import { AxiosInstance } from "axios";
export declare const getGQLUrls: (network: Network) => {
    ws: string;
    http: string;
} | undefined;
export declare const graphqlRequest: (httpClient: AxiosInstance, queryObj: {
    query: string;
    variables: any;
}) => Promise<import("axios").AxiosResponse<any, any>>;
export declare const graphQlUrls$: import("rxjs").Observable<{
    ws: string;
    http: string;
}>;
export declare const queryGql$: (client: AxiosInstance, queryObj: {
    query: string;
    variables: any;
}) => import("rxjs").Observable<any>;

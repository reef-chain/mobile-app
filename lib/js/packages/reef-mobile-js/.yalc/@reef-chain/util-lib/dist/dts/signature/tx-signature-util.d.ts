import { Provider } from "@reef-chain/evm-provider";
import { Fragment, JsonFragment } from "@ethersproject/abi";
export interface DecodedMethodData {
    methodName: string;
    args: string[];
    info: string;
    vm: {
        evm?: {
            contractAddress: string;
            decodedData: any;
        };
    };
}
export declare function getContractAbi(contractAddress: string): Promise<any[]>;
export declare function decodePayloadMethod(provider: Provider, methodDataEncoded: string, abi?: string | readonly (string | Fragment | JsonFragment)[], types?: any): Promise<DecodedMethodData | null>;

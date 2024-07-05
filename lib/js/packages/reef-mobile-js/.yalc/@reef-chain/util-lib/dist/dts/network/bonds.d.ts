import { Token } from "../token";
import { NetworkName } from "./network";
export interface Bond {
    name: string;
    description: string;
    contractAddress: string;
    validatorAddress: string;
    stake: Token;
    farm: Token;
    apy: string;
}
export declare const bonds: Record<NetworkName, Bond[]>;

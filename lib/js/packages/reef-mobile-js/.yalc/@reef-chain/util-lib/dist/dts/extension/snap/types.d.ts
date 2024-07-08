import { MetaMaskInpageProvider } from "@metamask/providers";
type This = typeof globalThis;
export interface Web3Window extends This {
    ethereum: MetaMaskInpageProvider & {
        setProvider?: (provider: MetaMaskInpageProvider) => void;
        detected?: MetaMaskInpageProvider[];
        providers?: MetaMaskInpageProvider[];
    };
}
export type GetSnapsResponse = Record<string, Snap>;
export type Snap = {
    permissionName: string;
    id: string;
    version: string;
    initialPermissions: Record<string, unknown>;
};
export interface SendSnapRequest {
    (message: string, request?: any): Promise<any>;
    (message: string, request: any, subscriber: (data: any) => void): Promise<any>;
}
export {};

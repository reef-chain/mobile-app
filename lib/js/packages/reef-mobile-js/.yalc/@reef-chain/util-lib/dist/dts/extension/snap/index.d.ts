import type { MetaMaskInpageProvider } from "@metamask/providers";
import type { GetSnapsResponse, Snap } from "./types";
export declare const SNAP_ID = "npm:@reef-chain/reef-snap";
export declare const getSnaps: (provider?: MetaMaskInpageProvider) => Promise<GetSnapsResponse>;
export declare const connectSnap: () => Promise<void>;
export declare const getSnap: () => Promise<Snap | undefined>;
export declare const sendToSnap: (message: string, request?: any) => Promise<any>;

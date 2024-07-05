import { Observable } from "rxjs";
import { ContractType, NFT } from "../../token/tokenModel";
import { ReefAccount } from "../../account/accountModel";
import { StatusDataObject } from "../model/statusDataObject";
import { AxiosInstance } from "axios";
import { IpfsUrlResolverFn } from "../ipfsUrlResolverFn";
export declare let _NFT_IPFS_RESOLVER_FN: IpfsUrlResolverFn | undefined;
export declare const setNftIpfsResolverFn: (val?: IpfsUrlResolverFn) => void;
export interface VerifiedNft {
    token: {
        id: string;
        type: ContractType.ERC1155 | ContractType.ERC721;
    };
    balance: string;
    nftId: string;
}
export declare const loadSignerNfts: ([httpClient, signer, forceReload, nftBalanceUpdated,]: [
    AxiosInstance,
    StatusDataObject<ReefAccount>,
    boolean,
    boolean
]) => Observable<StatusDataObject<StatusDataObject<NFT>[]>>;

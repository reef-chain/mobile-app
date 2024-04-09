import {graphql} from "@reef-chain/util-lib";
import { firstValueFrom } from "rxjs";

export const fetchNFTinfo = (
    httpClient: any,
    nftId: string,
    ownerAddress: string,
  ): Promise<any> => firstValueFrom(graphql.queryGql$(
                        httpClient, {
                         query: FETCH_NFT_INFO,
                         variables: {nftId, ownerAddress}
                       }))
    .then((verContracts: any)=> {
        const vContract = verContracts.data.tokenHolders[0];
        if (!vContract) return null;

        const nftInfo: any = {
         contractAddress:vContract.token.contract.id,
        } as any;
        return nftInfo;
    });

const FETCH_NFT_INFO = `
query FETCH_NFT_INFO($nftId: BigInt!,$ownerAddress: String!) {
    tokenHolders(where: {nftId_eq: $nftId , id_contains:$ownerAddress }, limit: 1) {
        token {
          contract {
            id
          }
        }
      }
  }  
`
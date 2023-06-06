import { gql } from '@apollo/client';


export const fetchNFTinfo = (
    apollo: any,
    nftId: string,
    ownerAddress: string,
  ): Promise<any> => apollo
    .query({
      query: FETCH_NFT_INFO_ANUKUL,
      variables: { nftId: nftId,ownerAddress:ownerAddress },
    })
    .then((verContracts: any) => {
      console.log("anuna "+nftId + ownerAddress);
        const vContract = verContracts.data.tokenHolders[0];
        if (!vContract) return null;

        const nftInfo: any = {
         contractAddress:vContract.token.contract.id,
        } as any;
        return nftInfo;
    })



const FETCH_NFT_INFO_ANUKUL = gql`
query FETCH_NFT_Info_anukul($nftId: BigInt!,$ownerAddress: String!) {
    tokenHolders(where: {nftId_eq: $nftId , id_contains:$ownerAddress }, limit: 1) {
        token {
          contract {
            id
          }
        }
      }
  }  
`
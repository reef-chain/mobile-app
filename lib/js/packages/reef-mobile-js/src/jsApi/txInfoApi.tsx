import { gql } from '@apollo/client';
import {graphql} from "@reef-chain/util-lib";


export const fetchTxInfo = (
    httpClient: any,
    searchTimestamp: string,
  ): Promise<TokenWithAmount> => /*apollo
    .query({
      query: FETCH_TX_INFO_ANUKUL,
      variables: { timestamp: searchTimestamp },
    })*/
    graphql.queryGql$(httpClient, {
      query: FETCH_TX_INFO_ANUKUL,
      variables: { timestamp: searchTimestamp },
    })
    .then((verContracts: any) => {
      console.log("anuna "+searchTimestamp);
        const vContract = verContracts.data.transfers[0];
        if (!vContract) return null;

        const txInfo: TxInfo = {
          age:vContract.timestamp,
          amount:vContract.amount,
          block_number:vContract.block.height,
          extrinsic: vContract.extrinsic.id,
          fee:vContract.extrinsic.signedData["fee"]["partialFee"],
          from:vContract.from.id,
          to:vContract.to.id,
          token_address:vContract.token.id,
          status:vContract.extrinsic.status,
          token_name:vContract.token.name,
          timestamp:vContract.timestamp,
          nftId:vContract.nftId,
          extrinsicIdx:vContract.extrinsic.index,
          eventIdx:vContract.block.events[0].index
        } as TxInfo;
        return txInfo;
    })



const FETCH_TX_INFO_ANUKUL = `
query FETCH_TX_Info_anukul($timestamp: DateTime!) {
    transfers(limit: 1, where: {timestamp_eq: $timestamp}) {
      id
      amount
      block {
        events(limit:1){
          index
        }
        height
      }
      nftId
      to {
        id
      }
      from {
        id
      }
      extrinsic {
        id
        index
        signedData
        status
      }
      token{
        id
        name
      }
      timestamp
    }
  }  
`

import {graphql} from "@reef-chain/util-lib";
import { firstValueFrom, timestamp } from "rxjs";

const TEXT_QUERY = `
query MyQuery {
  accounts(limit: 10) {
    availableBalance
    id
  }
}
`

export const fetchTxInfo = async (
    httpClient: any,
    searchTimestamp: string,
  ): Promise<TokenWithAmount|any> => {
    // return firstValueFrom(graphql.queryGql$(httpClient, {
    //   query: FETCH_TX_INFO_ANUKUL,
    //   variables: { timestamp: searchTimestamp },
    // }))
    // .then((verContracts: any) => {
    //   console.log("anuna "+searchTimestamp);
    //     const vContract = verContracts.data.transfers[0];
    //     if (!vContract) return null;

    //     const txInfo: TxInfo = {
    //       age:vContract.timestamp,
    //       amount:vContract.amount,
    //       block_number:vContract.block.height,
    //       extrinsic: vContract.extrinsic.id,
    //       fee:vContract.extrinsic.signedData["fee"]["partialFee"],
    //       from:vContract.from.id,
    //       to:vContract.to.id,
    //       token_address:vContract.token.id,
    //       status:vContract.extrinsic.status,
    //       token_name:vContract.token.name,
    //       timestamp:vContract.timestamp,
    //       nftId:vContract.nftId,
    //       extrinsicIdx:vContract.extrinsic.index,
    //       eventIdx:vContract.block.events[0].index
    //     } as TxInfo;
    //     return txInfo;
    // })

const FETCH_TX_INFO_ANUKUL = `
query FETCH_TX_Info_anukul {
    transfers(limit: 1, where: {timestamp_eq: "${searchTimestamp}"}) {
      id
      amount
      nftId
      to {
        id
      }
      from {
        id
      }
      token{
        id
        name
      }
      timestamp
      blockHeight
      eventIndex
      extrinsicIndex
      success
    }
  }  
`
try {
  const txResponse = await firstValueFrom(graphql.queryGql$(httpClient, {
    query: FETCH_TX_INFO_ANUKUL,
  }))

  const txData = (txResponse as any).data.transfers[0];

  const EXTRINSIC_HASH_QUERY = `query MyQuery {
    extrinsics(limit: 1, where: {index_eq: ${txData.extrinsicIndex}, block: {height_eq: ${txData.blockHeight},events_some: {index_eq: ${txData.eventIndex}}}}){
      hash
      signedData
    }
  }
  `
  const extrinsicResponse = await firstValueFrom(graphql.queryGql$(httpClient, {
    query: EXTRINSIC_HASH_QUERY,
  }))


  const extrinsicData = (extrinsicResponse as any).data.extrinsics[0];

  const txInfo: TxInfo = {
    age:txData.timestamp,
    amount:txData.amount,
    block_number:txData.blockHeight,
    extrinsic: extrinsicData.hash,
    fee:extrinsicData.signedData["fee"]["partialFee"],
    // fee:'0',
    from:txData.from.id,
    to:txData.to.id,
    token_address:txData.token.id,
    status:txData.success==true?'success':'failed',
    token_name:txData.token.name,
    timestamp:txData.timestamp,
    nftId:txData.nftId,
    extrinsicIdx:txData.extrinsicIndex,
    eventIdx:txData.eventIndex
  } as TxInfo;
  return txInfo;
} catch (error) {
  console.log(`ERR=== ${error}`)
  }
  return undefined;
}
// @anukulpandey pending data to add
// extrinsic {
//   id
//   signedData
// }
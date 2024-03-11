import {graphql} from "@reef-chain/util-lib";
import { firstValueFrom } from "rxjs";


export const fetchTxInfo = async (
    httpClient: any,
    searchTimestamp: string,
  ): Promise<TokenWithAmount|any> => {
const FETCH_TX_INFO = `
query FETCH_TX_INFO {
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
    query: FETCH_TX_INFO,
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
  console.log(`fetchTxInfo ERR= ${error.message}`)
  }
  return undefined;
}
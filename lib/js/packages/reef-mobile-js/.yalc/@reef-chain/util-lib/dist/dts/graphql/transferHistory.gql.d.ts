export declare const TRANSFER_HISTORY_QUERY = "\n  query transferHistory($accountId: String!) {\n    transfers(\n      where: {\n        OR: [{ from: { id_eq: $accountId } }, { to: { id_eq: $accountId } }]\n      }\n      limit: 35\n      orderBy: timestamp_DESC\n    ) {\n      timestamp\n      amount\n      fromEvmAddress\n      id\n      nftId\n      success\n      type\n      toEvmAddress\n      token {\n        id\n        name\n        type\n        contractData\n      }\n      signedData\n      extrinsicHash\n      extrinsicId\n      eventIndex\n      extrinsicIndex\n      blockHeight\n      blockHash\n      finalized\n      reefswapAction\n      from {\n        id\n        evmAddress\n      }\n      to {\n        id\n        evmAddress\n      }\n      reefswapAction\n    }\n  }\n";
export declare const getSignerHistoryQuery: (accountId: string) => {
    query: string;
    variables: {
        accountId: string;
    };
};

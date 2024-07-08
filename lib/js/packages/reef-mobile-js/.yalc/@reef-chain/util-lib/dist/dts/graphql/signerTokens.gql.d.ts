export declare const SIGNER_TOKENS_QUERY = "\n  query tokens_query($accountId: String!) {\n    tokenHolders(\n      where: {\n        AND: {\n          nftId_isNull: true\n          token: { id_isNull: false }\n          signer: { id_eq: $accountId }\n          balance_gt: \"0\"\n        }\n      }\n      orderBy: balance_DESC\n      limit: 320\n    ) {\n      token {\n        id\n      }\n      balance\n    }\n  }\n";
export declare const getSignerTokensQuery: (address: string) => {
    query: string;
    variables: {
        accountId: string;
    };
};

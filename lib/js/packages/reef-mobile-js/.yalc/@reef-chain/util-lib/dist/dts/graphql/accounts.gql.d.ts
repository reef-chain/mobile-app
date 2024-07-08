export declare const EVM_ADDRESS_UPDATE_QUERY = "\n  query evmAddresses($accountIds: [String!]!) {\n    accounts(where: { id_in: $accountIds }, orderBy: timestamp_DESC) {\n      id\n      evmAddress\n    }\n  }\n";
export declare const getEvmAddressQuery: (accountIds: string[]) => {
    query: string;
    variables: {
        accountIds: string[];
    };
};

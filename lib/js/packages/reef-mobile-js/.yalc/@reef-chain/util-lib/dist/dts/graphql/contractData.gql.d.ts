export declare const getContractDataQuery: (addresses: string[]) => {
    query: string;
    variables: {
        addresses: string[];
    };
};
export declare const getContractAbiQuery: (address: string) => {
    query: string;
    variables: {
        address: string;
    };
};

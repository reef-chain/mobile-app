
export const getDexUrl = (network:string):string=>{
    if(network=="testnet")return "https://squid.subsquid.io/reef-swap-testnet/graphql"
    return "https://squid.subsquid.io/reef-swap/graphql"
}

export const getExplorerUrl = (network:string):string=>{
    if(network=="testnet")return "https://squid.subsquid.io/reef-explorer-testnet/graphql"
    return "https://squid.subsquid.io/reef-explorer/graphql"
}
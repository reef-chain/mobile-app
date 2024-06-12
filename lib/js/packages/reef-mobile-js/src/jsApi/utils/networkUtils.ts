
export const getDexUrl = (network:string):string=>{
    if(network=="testnet")return "https://squid.subsquid.io/reef-swap-testnet/graphql"
    return "https://squid.subsquid.io/reef-swap/graphql"
}
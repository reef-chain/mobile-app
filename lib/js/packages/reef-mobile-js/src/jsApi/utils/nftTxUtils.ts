import { Contract } from "ethers";
import { Signer as EvmProviderSigner, Provider } from "@reef-defi/evm-provider";

export const nftTxAbi = [
    {
      "name": "safeTransferFrom",
      "type": "function",
      "inputs": [
        {
          "name": "from",
          "type": "address"
        },
        {
          "name": "to",
          "type": "address"
        },
        {
          "name": "id",
          "type": "uint256"
        },
        {
          "name": "amount",
          "type": "uint256"
        },
        {
          "name": "data",
          "type": "bytes"
        }
      ],
      "outputs": [],
      "stateMutability": "nonpayable"
    }
]

export const sendNft = async(signerOrProvider: EvmProviderSigner)=>{
    console.log("anuna is here");
    try {
        const poolContract = new Contract ("0x0601202b75C96A61CDb9A99D4e2285E43c6e60e4", nftTxAbi, signerOrProvider);
    
        const response = await poolContract.safeTransferFrom("5EnY9eFwEDcEJ62dJWrTXhTucJ4pzGym4WZ2xcDKiT3eJecP","5CwoHDBrNGJwMVdS2G2esBBqfaoBw3KmS1Tizv92xeAadSpz",19,1,[]);
        console.log(response);
    } catch (error) {
        console.log(error);
    }
}
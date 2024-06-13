import { reefState ,network as nw, getAccountSigner} from '@reef-chain/util-lib';
import { switchMap, take } from "rxjs/operators";
import { Contract} from "ethers";
import { ReefswapRouter } from "./abi/ReefswapRouter";
import { combineLatest, firstValueFrom } from "rxjs";
import { calculateAmount, calculateAmountWithPercentage, calculateDeadline, getInputAmount, getOutputAmount } from "./utils/math";
import { approveTokenAmount } from './utils/tokenUtils';
import { getPoolReserves } from './utils/poolUtils';
import Signer from "./background/Signer";

interface SwapSettings {
    deadline: number;
    slippageTolerance: number;
}

const defaultSwapSettings: SwapSettings = {
    deadline: 1,
    slippageTolerance: 0.8
};

const resolveSettings = (
    { deadline, slippageTolerance }: SwapSettings,
  ): SwapSettings => ({
    deadline: Number.isNaN(deadline) ? defaultSwapSettings.deadline : deadline,
    slippageTolerance: Number.isNaN(slippageTolerance) ? defaultSwapSettings.slippageTolerance : slippageTolerance,
  });

export const initApi = (signingKey: Signer) => {
    (window as any).swap = {
        // Executes a swap
        execute: async (signerAddress: string, token1: TokenWithAmount, token2: TokenWithAmount, settings: SwapSettings) => {
            return firstValueFrom(
                combineLatest([reefState.selectedNetwork$, reefState.accounts$,reefState.selectedProvider$]).pipe(
                    take(1),
                    switchMap(async ([network, reefSigners,provider]) => {
                        const reefSigner = reefSigners.find((s)=>s.address===signerAddress);
                    
                        if (!reefSigner) {
                            console.log("swap.send() - NO SIGNER FOUND",);
                            return false;
                        }

                        settings = resolveSettings(settings);
                        const sellAmount = calculateAmount({ decimals: token1.decimals, amount: token1.amount });
                       
                        const minBuyAmount = calculateAmountWithPercentage(
                            { decimals: token2.decimals, amount: token2.amount },
                            settings.slippageTolerance
                        );
                        console.log("here i am ssellAmount",minBuyAmount);
                        const signer = await getAccountSigner(reefSigner.address,provider,signingKey)
                        const swapRouter = new Contract(
                            nw.getReefswapNetworkConfig(network).routerAddress,
                            ReefswapRouter,
                            signer,
                        );

                        try {
                            // Approve token1
                            await approveTokenAmount(
                                token1.address,
                                sellAmount,
                                nw.getReefswapNetworkConfig(network).routerAddress,
                                signer,
                            );
                            console.log("Token approved");

                            // Swap
                            console.log("Waiting for confirmation of swap...");
                            const tx = await swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                              sellAmount,
                              minBuyAmount,
                              [token1.address, token2.address],
                              reefSigner.evmAddress,
                              calculateDeadline(settings.deadline)
                            );
                            const receipt = await tx.wait();
                            console.log("SWAP RESULT=", receipt);

                            return receipt;
                        } catch (e) {
                            console.log("ERROR swapping tokens", e);
                            return null;
                        }
                    }),
                    take(1)
                )
            );
        },
        // Returns pool reserves, if pool exists
        getPoolReserves: async (token1Address: string, token2Address: string) => {
            return firstValueFrom(
                combineLatest([reefState.selectedNetwork$, reefState.selectedProvider$]).pipe(
                    take(1),
                    switchMap(async ([network, provider]) => {
                        return getPoolReserves(token1Address, token2Address, provider, nw.getReefswapNetworkConfig(network).factoryAddress);
                    }),
                    take(1)
                )
            );
        },
        /*
        * buy == true
        *     tokenAmount: amount of token2 to buy
        *     returns amount of token1 required
        * buy == false
        *     tokenAmount: amount of token1 to sell
        *     returns amount of token2 received
        */
        getSwapAmount:(tokenAmount: string, buy: boolean, token1Reserve: TokenWithAmount, token2Reserve: TokenWithAmount) => {
            return buy ? getInputAmount(tokenAmount, token1Reserve, token2Reserve) : getOutputAmount(tokenAmount, token1Reserve, token2Reserve);
        }
    }
}

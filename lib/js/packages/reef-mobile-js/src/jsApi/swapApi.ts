import { reefState ,network as nw, getAccountSigner} from '@reef-chain/util-lib';
import { switchMap, take } from "rxjs/operators";
import { BigNumber, Contract} from "ethers";
import { ReefswapRouter } from "./abi/ReefswapRouter";
import { Observable, combineLatest, firstValueFrom } from "rxjs";
import { calculateAmount, calculateAmountWithPercentage, calculateDeadline, getInputAmount, getOutputAmount } from "./utils/math";
import { approveTokenAmount, getREEF20Contract } from './utils/tokenUtils';
import { getPoolReserves } from './utils/poolUtils';
import Signer from "./background/Signer";
import { Signer as ReefSigner } from '@reef-chain/evm-provider';
import { toBN } from '@reef-chain/evm-provider/utils';
import { extension as extReef } from '@reef-chain/util-lib';

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

const hexToAscii = (str1: string): string => {
    const hex = str1.toString();
    let str = '';
    for (let n = 0; n < hex.length; n += 2) {
        str += String.fromCharCode(parseInt(hex.substr(n, 2), 16));
    }
    return str;
};

const captureError = (events: Event[]): string|undefined => {
    for (const event of events) {
      const eventCompression = `${(event as any).event.section.toString()}.${(event as any).event.method.toString()}`;
      if (eventCompression === 'evm.ExecutedFailed') {
        const eventData = ((event as any).event.data.toJSON() as any[]);
        let message = eventData[eventData.length - 2];
        if (typeof message === 'string' || message instanceof String) {
          message = hexToAscii(message.substring(138));
        } else {
          message = JSON.stringify(message);
        }
        return message;
      }
    }
    return undefined;
  };

  const getReefCoinBalance = async (
    address: string,
    provider: any,
  ): Promise<any> => {
    const balance = await provider.api.derive.balances
      .all(address as any)
      .then((res: any) => BigNumber.from(res.freeBalance.toString(10)));
    return balance;
  };

  const signerToReefSigner = async (
    signer: ReefSigner,
    provider: any,
    {
      address, name, source, genesisHash,
    }: any,
  ): Promise<any> => {
    const evmAddress = await signer.getAddress();
    const isEvmClaimed = await signer.isClaimed();
    let inj;
    try {
      inj = await extReef.web3FromAddress(address);
    } catch (e) {
      // when web3Enable() is not called before
    }
    const balance = await getReefCoinBalance(address, provider);
    return {
      signer,
      balance,
      evmAddress,
      isEvmClaimed,
      name,
      address,
      source,
      genesisHash: genesisHash!,
      sign: inj?.signer,
    };
  };

  const accountToSigner = async (
    account: any,
    provider: any,
    sign: any,
    source: string,
  ): Promise<any> => {
    const signer = new ReefSigner(provider, account.address, sign);
    return signerToReefSigner(
      signer,
      provider,
      {
        source,
        address: account.address,
        name: account.name || '',
        genesisHash: account.genesisHash || '',
      },
    );
  };

export const initApi = (signingKey: Signer) => {
    (window as any).swap = {
        // Executes a swap
        execute: (signerAddress, token1, token2, settings) => {
            return new Observable((observer) => {
                (async () => {
                    try {
                        observer.next({ status: 'approving' });
                        const [network, reefSigners, provider] = await firstValueFrom(
                            combineLatest([reefState.selectedNetwork$, reefState.accounts$, reefState.selectedProvider$]).pipe(take(1))
                        );
        
                        const reefSigner = reefSigners.find((s) => s.address === signerAddress);
        
                        if (!reefSigner) {
                            console.log("swap.send() - NO SIGNER FOUND");
                            observer.error(new Error('No signer found'));
                            return;
                        }
        
                        settings = resolveSettings(settings);
                        const sellAmount = calculateAmount({ decimals: token1.decimals, amount: token1.amount });
        
                        const minBuyAmount = calculateAmountWithPercentage(
                            { decimals: token2.decimals, amount: token2.amount },
                            settings.slippageTolerance
                        );
                        const {signer} = await accountToSigner(reefSigner, provider, signingKey,"injected");
                      

                        const swapRouter = new Contract(
                            nw.getReefswapNetworkConfig(network).routerAddress,
                            ReefswapRouter,
                            signer,
                        );
        
                        try {
                            observer.next({ status: 'approve-started' });

                            // Approve token1
                            const tokenContract = await getREEF20Contract(token1.address, signer);
                            let approveTransaction = 
                                await tokenContract
                                    .populateTransaction
                                    .approve(
                                        nw.getReefswapNetworkConfig(network).routerAddress,
                                        sellAmount
                                    );

                            observer.next({ status: 'approved' });
        
                            // Swap
                            const tradeTransaction = await swapRouter.populateTransaction.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                                sellAmount,
                                minBuyAmount,
                                [token1.address, token2.address],
                                reefSigner.evmAddress,
                                calculateDeadline(settings.deadline)
                            );


                            const approveResources = await signer.provider.estimateResources(approveTransaction);
        
                            const approveExtrinsic = signer.provider.api.tx.evm.call(
                                approveTransaction.to,
                                approveTransaction.data,
                                toBN(approveTransaction.value || 0),
                                toBN(approveResources.gas),
                                approveResources.storage.lt(0) ? toBN(0) : toBN(approveResources.storage),
                            );

                            const tradeExtrinsic = signer.provider.api.tx.evm.call(
                                tradeTransaction.to,
                                tradeTransaction.data,
                                toBN(tradeTransaction.value || 0),
                                toBN(582938 * 2), // hardcoded gas estimation, multiply by 2 as a safety margin
                                toBN(64 * 2), // hardcoded storage estimation, multiply by 2 as a safety margin
                              );
                        
                              // Batching extrinsics
                              const batch = signer.provider.api.tx.utility.batchAll([
                                approveExtrinsic,
                                tradeExtrinsic,
                              ]);
                        
                              // Signing and awaiting when data comes in block
                              const signAndSend = new Promise<void>((resolve, reject): void => {
                                batch.signAndSend(
                                    reefSigner.address,
                                  { signer: signer.signingKey },
                                  (status: any) => {
                                    const err = captureError(status.events);
                                    if (err) {
                                      reject({ message: err });
                                    }
                                    if (status.dispatchError) {
                                      reject({ message: status.dispatchError.toString() });
                                    }
                                    if (status.status.isInBlock) {
                                      resolve();
                                    }
                                    // If you want to await until block is finalized use below if
                                    if (status.status.isFinalized) {
                                        
                                    }
                                  },
                                );
                              });
                            await signAndSend;

                            // observer.next({ status: 'broadcast', transactionResponse: tx });
        
                            // const receipt = await tx.wait();
                            // console.log("SWAP RESULT=", receipt);
                            observer.next({ status: 'included-in-block', transactionReceipt: "receipt" });
                            observer.next({ status: 'finalized', transactionReceipt: "receipt" });
                            observer.complete();
        
                        } catch (e) {
                            console.log("ERROR swapping tokens", e.message);
                            observer.next({status:e.message});
                        }
                    } catch (e) {
                        console.log("ERROR in swap process", e);
                        observer.error(e);
                    }
                })();
            });
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

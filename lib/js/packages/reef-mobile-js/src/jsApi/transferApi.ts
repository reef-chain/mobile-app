import {FlutterJS} from "flutter-js-bridge/src/FlutterJS";
import {appState, Token, TokenWithAmount, ReefSigner, reefTokenWithAmount} from '@reef-defi/react-lib';
import {map, switchMap, take} from "rxjs/operators";
import {BigNumber, Contract} from "ethers";
import { Provider } from "@reef-defi/evm-provider";
import { ERC20 } from "./transfer/abi/ERC20";
import { firstValueFrom } from "rxjs";

const REEF_ADDRESS = reefTokenWithAmount().address;

const assertAmount = (amount?: string): string => (!amount ? '0' : amount);

const findDecimalPoint = (amount: string): number => {
    const { length } = amount;
    let index = amount.indexOf(',');
    if (index !== -1) {
        return length - index - 1;
    }
    index = amount.indexOf('.');
    if (index !== -1) {
        return length - index - 1;
    }
    return 0;
};

const transformAmount = (decimals: number, amount: string): string => {
    if (!amount) {
        return '0'.repeat(decimals);
    }
    const addZeros = findDecimalPoint(amount);
    const cleanedAmount = amount.replace(/,/g, '').replace(/\./g, '');
    return cleanedAmount + '0'.repeat(Math.max(decimals - addZeros, 0));
};

interface CalculateAmount {
    decimals: number;
    amount: string;
}

const calculateAmount = ({ decimals, amount }: CalculateAmount): string => BigNumber.from(transformAmount(decimals, assertAmount(amount))).toString();

const nativeTransfer = async (amount: string, destinationAddress: string, provider: Provider, signer: ReefSigner): Promise<void> => {
    try {
        await provider.api.tx.balances
            .transfer(destinationAddress, amount)
            .signAndSend(signer.address, { signer: signer.signer.signingKey });
    } catch (e) {
        console.log(e);
    }
};

const getSignerEvmAddress = async (address: string, provider: Provider): Promise<string> => {
    if (address.length !== 48 || address[0] !== '5') {
        return address;
    }
    const evmAddress = await provider.api.query.evmAccounts.evmAddresses(address);
    const addr = (evmAddress as any).toString();

    if (!addr) {
        throw new Error('EVM address does not exist');
    }
    return addr;
};

export const initApi = (flutterJS: FlutterJS) => {
    (window as any).transfer = {
        send: async (from: string, to: string, tokenAmount: string, tokenDecimals: number, tokenAddress: string) => {
            return firstValueFrom(appState.signers$.pipe(
                take(1),
                map((signers: ReefSigner[]) => {
                    return signers.find((s)=>s.address===from);
                }),
                switchMap(async (signer: ReefSigner | undefined) => {
                    if (!signer) {
                        console.log("transfer.send() - NO SIGNER FOUND",);
                        return false
                    }
                    const STORAGE_LIMIT = 2000;
                    const amount = calculateAmount ({ decimals: tokenDecimals, amount: tokenAmount });
                    const { provider } = signer.signer;
                    const tokenContract = new Contract(tokenAddress, ERC20, signer.signer);
                    try {
                        if (tokenAddress === REEF_ADDRESS && to.length === 48) {
                            console.log ('transfering native REEF');
                            console.log (amount, amount.toString ());
                            await nativeTransfer(amount, to, provider, signer);
                            console.log ('transfer success');
                            return true;
                        } else {
                            console.log ('transfering REEF20');
                            console.log (amount, amount.toString());
                            const toAddress = to.length === 48
                                ? await getSignerEvmAddress(to, provider)
                                : to;
                            const ARGS = [toAddress, amount];
                            console.log ("args=",ARGS);
                            const tx = await tokenContract ['transfer'] (...ARGS, {
                                customData: {
                                    storageLimit: STORAGE_LIMIT
                                }
                            });
                            console.log ('tx in progress =', tx.hash);
                            const receipt = await tx.wait();
                            console.log("SIGN AND SEND RESULT=", receipt.transactionHash);
                            console.log ('transfer success');
                            return receipt;
                        }
                    } catch (e) {
                        console.log('EEEEEE',e);
                        return null;
                    }
                }),
                take(1)
            ));
        }
    }
}
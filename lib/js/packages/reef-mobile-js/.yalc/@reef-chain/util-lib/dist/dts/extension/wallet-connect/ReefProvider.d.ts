import { Provider } from "@reef-chain/evm-provider";
import { SessionTypes } from "@walletconnect/types";
import { ReefInjectedProvider, Unsubcall } from "../extension-inject/types";
export default class ReefProvider implements ReefInjectedProvider {
    private rpcUrl;
    private provider;
    constructor(_session: SessionTypes.Struct);
    subscribeSelectedNetwork(cb: (rpcUrl: string) => void): void;
    subscribeSelectedNetworkProvider(cb: (provider: Provider) => void): Unsubcall;
    getNetworkProvider(): Promise<Provider>;
}

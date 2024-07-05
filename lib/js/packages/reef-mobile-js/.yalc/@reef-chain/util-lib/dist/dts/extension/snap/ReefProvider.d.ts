import { Provider } from "@reef-chain/evm-provider";
import { ReefInjectedProvider, Unsubcall } from "../extension-inject/types";
import { SendSnapRequest } from "./types";
export default class ReefProvider implements ReefInjectedProvider {
    private readonly sendRequest;
    private rpcUrl;
    private provider;
    constructor(_sendRequest: SendSnapRequest);
    subscribeSelectedNetwork(cb: (rpcUrl: string) => void): void;
    subscribeSelectedNetworkProvider(cb: (provider: Provider) => void): Unsubcall;
    getNetworkProvider(): Promise<Provider>;
}

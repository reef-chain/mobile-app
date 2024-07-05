import { InjectOptions } from "../extension-inject";
import { WcConnection } from "./connect";
export declare function injectWcAsExtension({ client, session }: WcConnection, { name, version }: InjectOptions): void;

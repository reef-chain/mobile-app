import type { InjectedMetadata, InjectedMetadataKnown, MetadataDef } from "../extension-inject/types";
import { SendSnapRequest } from "./types";
export default class Metadata implements InjectedMetadata {
    constructor(_sendRequest: SendSnapRequest);
    get(): Promise<InjectedMetadataKnown[]>;
    provide(definition: MetadataDef): Promise<boolean>;
}

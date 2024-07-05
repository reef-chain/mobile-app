import { Observable } from "rxjs";
export declare function getEvmEvents$(contractAddress: string, methodSignature?: string, fromBlockId?: number, toBlockId?: number): Observable<{
    fromBlockId: number;
    toBlockId: number;
    evmEvents: any[];
} | null>;

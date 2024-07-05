import { Observable } from "rxjs";
export declare enum FeedbackStatusCode {
    _ = 0,
    LOADING = 1,
    PARTIAL_DATA_LOADING = 2,
    MISSING_INPUT_VALUES = 3,
    NOT_SET = 4,
    ERROR = 5,
    COMPLETE_DATA = 6
}
export interface FeedbackStatus {
    code: FeedbackStatusCode;
    message?: string;
    propName?: string;
    oldData?: any;
}
export declare class StatusDataObject<T> {
    data: T;
    private _status;
    constructor(data: T, status: FeedbackStatus[]);
    getStatus(propName?: string): FeedbackStatus[];
    hasStatus(status: FeedbackStatusCode | FeedbackStatusCode[], propName?: string): boolean;
    setStatus(statArr: FeedbackStatus[]): void;
    getStatusList(): FeedbackStatus[];
    toJson(): string;
}
export declare const toFeedbackDM: <T>(data: T, statCode?: FeedbackStatusCode | FeedbackStatusCode[] | FeedbackStatus[], message?: string, propName?: string) => StatusDataObject<T>;
export declare const isFeedbackDM: (value: StatusDataObject<any> | any) => boolean;
export declare const collectFeedbackDMStatus: (items: StatusDataObject<any>[]) => FeedbackStatusCode[];
export declare const findMinStatusCode: (feedbackDMs: (StatusDataObject<any> | undefined)[]) => FeedbackStatusCode;
export declare function skipBeforeStatus$<T>(observable: Observable<StatusDataObject<T>>, status: FeedbackStatusCode): Observable<StatusDataObject<T>>;

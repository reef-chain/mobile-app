import { Observable, Subject, firstValueFrom } from "rxjs";


export const initApi = async(flutterWsMessageObs: Observable<Subject<{data:any}>>)=>{
    
    (window as any).wsBridge = {
        getWsBridgeObs:async()=>{
            return flutterWsMessageObs;
        },
    }
}
import { Subject } from 'rxjs';

class WsBridge extends WebSocket {
  private messageSubject: Subject<{ type: string; data: any }>;

  constructor(url: string, protocols?: string | string[]) {
    super(url, protocols);
    this.messageSubject = new Subject<{ type: string; data: any }>();
  }

// should send to WsBridge.dart 
  override send(data: string | ArrayBuffer | Blob | ArrayBufferView): void {
    this.messageSubject.next({ type: 'send', data });
  }

 //on receiving any message, should send to WsBridge.dart and listen to acknowldegment from there
  override onmessage: (this: WebSocket, ev: MessageEvent) => any = (ev: MessageEvent) => {
    this.messageSubject.next({ type: 'received', data: ev.data });
  };

  // Method to get the message subject as observable to subscribe
  public get messageObservable() {
    return this.messageSubject.asObservable();
  }
}

export const wsBridge ={
    getWsBridge:(url:string)=>{
        const wsBridgeConn = new WsBridge(url);
        return wsBridgeConn.messageObservable;
    },
}
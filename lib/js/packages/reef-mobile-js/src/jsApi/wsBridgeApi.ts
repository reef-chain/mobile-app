import { Subject } from 'rxjs';

export class WsBridge extends WebSocket {
  private messageSubject: Subject<{ type: string; data: any }>;

  constructor(url: string, protocols?: string | string[]) {
    super(url, protocols);
    this.messageSubject = new Subject<{ type: string; data: any }>();
  }

// should send to WsBridge.dart 
  override send(data: string | ArrayBuffer | Blob | ArrayBufferView): void {
    this.messageSubject.next({ type: 'send', data });
  }

 //on receiving any message from js, should be emitted
  messageFromFlutter(data){
    this.onmessage(data)
  }

  // Method to get the message subject as observable to subscribe
  public get messageObservable() {
    return this.messageSubject.asObservable();
  }
}

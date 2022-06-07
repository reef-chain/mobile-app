import {interval, map} from 'rxjs';
import {FlutterJS} from "./service/flutterConnectService";

window['flutterJS'] = new FlutterJS();

window['testObs'] = interval().pipe(
    map((value) => {
        return {value, msg:'hey'}
    })
);

window['testApi'] = function (param){
    console.log('js test log', {value:'test123'});
    return {id:'123', value:{works:'ok', param}};
}


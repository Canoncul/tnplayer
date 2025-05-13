import 'package:obs_websocket/obs_websocket.dart';

responseToString(RequestResponse? response, String functionName) {
  if (response == null) {
    print("Error");
  } else if (response.requestStatus.result == false) {
    print("Error: $functionName - ${response.requestStatus.comment}");
  }
  // else {
  //   print("Result: $functionName - ${response.responseData.toString()}");
  // }
}

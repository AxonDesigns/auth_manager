import 'dart:async';

executeOnSeconds(void Function(Timer? timer) callback) {
  var now = DateTime.now();
  var nextSecond = now.add(const Duration(seconds: 1));
  Timer(nextSecond.difference(now), () {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      callback(timer);
    });
    callback(null);
  });
}

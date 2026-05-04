import 'dart:async';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Gunakan GetxService, bukan GetxController
class TimeService extends GetxService {
  var currentTime = DateTime.now().obs;
  var selectedTimeZone = 'Auto'.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _startClock();
  }

  void _startClock() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      currentTime.value = DateTime.now();
    });
  }

  String get formattedTime {
    DateTime timeToDisplay;
    String zoneName = '';

    if (selectedTimeZone.value == 'Auto') {
      timeToDisplay = currentTime.value;
      zoneName = timeToDisplay.timeZoneName;

      if (zoneName.contains('+07')) zoneName = 'WIB';
      if (zoneName.contains('+08')) zoneName = 'WITA';
      if (zoneName.contains('+09')) zoneName = 'WIT';
      if (zoneName.contains('+01')) zoneName = 'BST';
      if(zoneName.contains('+00')) zoneName = 'UTC';
    } else {
      DateTime utcTime = currentTime.value.toUtc();

      if (selectedTimeZone.value == 'WIB') {
        timeToDisplay = utcTime.add(const Duration(hours: 7));
        zoneName = 'WIB';
      } else if (selectedTimeZone.value == 'WITA') {
        timeToDisplay = utcTime.add(const Duration(hours: 8));
        zoneName = 'WITA';
      } else if (selectedTimeZone.value == 'WIT') {
        timeToDisplay = utcTime.add(const Duration(hours: 9));
        zoneName = 'WIT';
      }else if (selectedTimeZone.value == 'BST') {
        timeToDisplay = utcTime.add(const Duration(hours: 1));
        zoneName = 'BST';
      }else if (selectedTimeZone.value == 'UTC') {
        timeToDisplay = utcTime;
        zoneName = 'UTC';
      }else {
        timeToDisplay = currentTime.value;
      }
    }

    String timeString = DateFormat('HH:mm:ss').format(timeToDisplay);
    return "$timeString $zoneName";
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
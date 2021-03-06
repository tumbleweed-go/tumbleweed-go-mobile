import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApiAccessor {
  static final baseUrl = 'https://tumbleweed-go-284013.ue.r.appspot.com/';

  static Future<Position> getCurrentLocation() async {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    return await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
  }

  static Future<Map<String, dynamic>> getTumbleweeds() async {
    final response = await http.get(baseUrl + 'tumbleweed/get');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return Future.error('Error ${response.statusCode}');
    }
  }

  static Future<int> uploadImage(String imagePath) async {
    final location = await getCurrentLocation();
    final url = baseUrl +
        'tumbleweed/upload/${location.latitude}/${location.longitude}';

    final request = http.MultipartRequest('POST', Uri.parse(url));
    final image = await http.MultipartFile.fromPath('image', imagePath);
    request.files.add(image);

    final response = await request.send().timeout(
      Duration(seconds: 10),
      onTimeout: () {
        return null;
      },
    );

    if (response != null) {
/*       final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData); */

      return response.statusCode;
    } else {
      return -1;
    }
  }
}

import 'package:http/http.dart' as http;
import 'package:universal_io/io.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class FnUriUtils {
  static void openDir(Directory directory) async {
    String directoryPath = directory.path;

    if (Platform.isMacOS) {
      directoryPath = 'file://$directoryPath';
    } else if (Platform.isWindows) {
      directoryPath = directoryPath.replaceAll('/', '\\');
    }

    print("Opening directory: $directoryPath");

    if (await canLaunch(directoryPath)) {
      await launch(directoryPath);
    } else {
      throw 'Could not open directory';
    }
  }

  static void openUrl(
    String url, {
    LaunchMode mode = LaunchMode.externalApplication,
  }) {
    launchUrl(Uri.parse(url), mode: mode);
  }

  // 访问 url

  static Future<String?> get(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // 如果服务器返回一个 OK 响应，那么解析 JSON
      print('Response data: ${response.body}');
      return response.body;
    } else {
      print("get fail; fail: ${response}");
      return null;
    }
  }
}

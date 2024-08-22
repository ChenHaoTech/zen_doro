import 'dart:convert';
import 'dart:io';

import 'package:dart_utils_extension/dart_utils_extension.dart';
import 'package:flutter_pasteboard/model/misc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AudioConfig', () {
    String _buildExtra(List<String> source) {
      return json.encode({
        "meta": source,
      });
    }

    var resource = [
      AudioConfig.fromUri("https://gitee.com/chen-hao91/publix_resource/raw/main/Nicaragua.mp3",
          extra: _buildExtra(["森林", "雨水"]), volumn: .5, name: "Nicaragua"),
      AudioConfig.fromUri(
          "https://gitee.com/chen-hao91/publix_resource/raw/main/%E7%BB%BF%E7%9A%AE%E7%81%AB%E8%BD%A6_%E7%88%B1%E7%BB%99%E7%BD%91_aigei_com.mp3",
          extra: _buildExtra(["火车"]),
          volumn: .5,
          name: "绿皮火车"),
      AudioConfig.fromUri(
          "https://gitee.com/chen-hao91/publix_resource/raw/main/%E7%99%BD%E5%99%AA%E9%9F%B3-%E6%A2%B5%E9%9F%B3_%E7%88%B1%E7%BB%99%E7%BD%91_aigei_com.mp3",
          extra: _buildExtra(["白噪音", "梵音"]),
          volumn: .5,
          name: "梵音"),
      AudioConfig.fromUri(
          "https://gitee.com/chen-hao91/publix_resource/raw/main/%E5%9F%8E%E5%B8%82%E9%AB%98%E6%A5%BC%E5%A4%A7%E5%8E%A6%E5%8A%9E%E5%85%AC%E6%A5%BC%E9%AB%98%E6%A5%BC%E5%B1%82%E5%A4%96%20%E8%BD%A6%E6%B0%B4%E9%A9%AC%E9%BE%99%20%E7%99%BD%E5%99%AA%E9%9F%B3_%E7%88%B1%E7%BB%99%E7%BD%91_aigei_com.m4a",
          extra: _buildExtra(["城市", "高楼办公区", "车水马龙"]),
          volumn: .5,
          name: "城市高楼大厦外车水马龙"),
      AudioConfig.fromUri("https://gitee.com/chen-hao91/publix_resource/raw/main/spring-birds-in-a-summer-loop-195105.mp3",
          extra: _buildExtra(["虫鸣鸟叫", "大自然", "夏天"]), volumn: .5, name: "虫鸣鸟叫"),
      AudioConfig.fromUri("https://gitee.com/chen-hao91/publix_resource/raw/main/sandy-beach-calm-waves-water-nature-sounds-8052.mp3",
          extra: _buildExtra(["沙滩", "海浪", "放松", "自然"]), volumn: .5, name: "沙滩海浪"),
      AudioConfig.fromUri("https://gitee.com/chen-hao91/publix_resource/raw/main/%E5%86%A5%E6%83%B3_%E9%9F%B3%E4%B9%90.mp3",
          extra: _buildExtra(["冥想", "放松"]), volumn: .5, name: "冥想音乐"),
      AudioConfig.fromUri("https://gitee.com/chen-hao91/publix_resource/raw/main/%E6%B7%85%E6%B2%A5%E6%B2%A5_%E5%B0%8F%E9%9B%A8.wav",
          extra: _buildExtra(["小雨", "大自然"]), volumn: .5, name: "淅沥沥的小雨"),
      AudioConfig.fromUri(
          "https://gitee.com/chen-hao91/publix_resource/raw/main/%E9%9D%92%E8%9B%99_%E6%B1%A0%E5%A1%98_%E5%85%AC%E8%B7%AF%E7%9B%98_%E5%A4%8F%E5%A4%A9_%E4%B8%8B%E9%9B%A8_%E6%B7%85%E6%B2%A5%E6%B2%A5.wav",
          extra: _buildExtra(["小雨", "大自然", "青蛙"]),
          volumn: .5,
          name: "淅沥沥小雨青蛙在池塘里叫"),
      AudioConfig.fromUri("https://gitee.com/chen-hao91/publix_resource/raw/main/%E9%A3%8E%E9%93%83%E6%B8%85%E8%84%86%E7%9A%84%E5%93%8D%E5%A3%B0.wav",
          extra: _buildExtra(["放松", "空灵"]), volumn: .5, name: "风铃清脆的响声"),
    ];
    print(resource.toJsonStr());
  });
}

import "package:universal_html/html.dart";

String getOSInsideWeb() {
  final userAgent = window.navigator.userAgent.toString().toLowerCase();
  if (userAgent.contains("iphone")) return "ios";
  if (userAgent.contains("ipad")) return "ios";
  if (userAgent.contains("android")) return "Android";
  return "Web";
}

bool isCanvasKit() {
  return window.document
      .querySelector("body")
      .attributes['flt-renderer']
      .contains("canvaskit");
}

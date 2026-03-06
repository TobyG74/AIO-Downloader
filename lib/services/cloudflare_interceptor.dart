import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'web_cookie_service.dart';

/// Auto-interceptor for Cloudflare protection or cookie requirements.
/// Launches WebView on 403 to get cookies and retries request.
class CloudflareInterceptor extends Interceptor {
  final BuildContext? context;
  final Map<String, bool> _handlingUrls = {};

  CloudflareInterceptor({this.context});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    
    if (response?.statusCode != 403) {
      return handler.next(err);
    }

    final requestOptions = response?.requestOptions;
    if (requestOptions == null) {
      return handler.next(err);
    }

    final requestUrl = requestOptions.uri.toString();
    final baseUrl = _getBaseUrl(requestUrl);
    
    if (_handlingUrls[baseUrl] == true) {
      return handler.next(err);
    }

    try {
      _handlingUrls[baseUrl] = true;

      final cookies = await _getCookiesViaWebView(baseUrl);
      
      if (cookies == null || cookies.isEmpty) {
        return handler.next(err);
      }
      
      await WebCookieService.instance.saveCookies(baseUrl, cookies);
      
      await Future.delayed(const Duration(milliseconds: 1500));

      final dio = Dio();
      dio.options = BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 '
              '(KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36',
          'Accept': '*/*',
          'Accept-Language': 'en-US,en;q=0.9',
          'Accept-Encoding': 'gzip, deflate, br',
          'Referer': baseUrl,
          'Origin': baseUrl,
          'Sec-Fetch-Dest': 'empty',
          'Sec-Fetch-Mode': 'cors',
          'Sec-Fetch-Site': 'same-origin',
          'Cookie': cookies,
        },
      );

      final retryResponse = await dio.request(
        requestUrl,
        data: requestOptions.data,
        options: Options(
          method: requestOptions.method,
          contentType: requestOptions.contentType,
        ),
      );

      return handler.resolve(retryResponse);
    } catch (e) {
      return handler.next(err);
    } finally {
      _handlingUrls.remove(baseUrl);
    }
  }

  Future<String?> _getCookiesViaWebView(String baseUrl) async {
    try {
      await WebCookieService.instance.invalidate(baseUrl);
      
      final completer = Completer<String?>();
      HeadlessInAppWebView? headlessWebView;

      headlessWebView = HeadlessInAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(baseUrl)),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          userAgent:
              'Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 '
              '(KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36',
          clearCache: false,
        ),
        onLoadStop: (controller, url) async {
          await Future.delayed(const Duration(milliseconds: 1500));
          
          try {
            final cookies = await CookieManager.instance().getCookies(
              url: WebUri(baseUrl),
            );

            if (cookies.isNotEmpty) {
              final cookieString = cookies.map((c) => '${c.name}=${c.value}').join('; ');
              await headlessWebView?.dispose();
              completer.complete(cookieString);
            } else {
              await headlessWebView?.dispose();
              completer.complete(null);
            }
          } catch (e) {
            await headlessWebView?.dispose();
            completer.complete(null);
          }
        },
        onLoadError: (controller, url, code, message) async {
          await headlessWebView?.dispose();
          completer.complete(null);
        },
      );

      await headlessWebView.run();

      return await completer.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          headlessWebView?.dispose();
          return null;
        },
      );
    } catch (e) {
      return null;
    }
  }

  String _getBaseUrl(String url) {
    final uri = Uri.parse(url);
    return '${uri.scheme}://${uri.host}';
  }
}
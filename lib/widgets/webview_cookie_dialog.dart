import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../l10n/app_localizations.dart';
import '../services/web_cookie_service.dart';

/// Universal WebView dialog for extracting cookies from websites.
class WebViewCookieDialog extends StatefulWidget {
  final String baseUrl;

  const WebViewCookieDialog({super.key, required this.baseUrl});

  static Future<String?> show(BuildContext context, String baseUrl) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WebViewCookieDialog(baseUrl: baseUrl),
    );
  }

  @override
  State<WebViewCookieDialog> createState() => _WebViewCookieDialogState();
}

class _WebViewCookieDialogState extends State<WebViewCookieDialog> {
  bool _pageLoaded = false;
  bool _verified = false;

  String get _domain {
    final uri = Uri.tryParse(widget.baseUrl);
    return uri?.host ?? widget.baseUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.72,
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1),
            Expanded(child: _buildWebView()),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          const Icon(Icons.security_rounded, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.webviewVerifyTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  _domain,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _closeWithCookieCheck,
          ),
        ],
      ),
    );
  }

  Widget _buildWebView() {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(widget.baseUrl)),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        userAgent:
            'Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 '
            '(KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36',
        clearCache: false,
        clearSessionCache: false,
      ),
      onLoadStop: (controller, url) async {
        if (!mounted) return;
        setState(() => _pageLoaded = true);
        
        await Future.delayed(const Duration(milliseconds: 1000));
        await _tryAutoClose();
      },
    );
  }

  Widget _buildFooter() {
    final l10n = AppLocalizations.of(context)!;
    
    if (_verified) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 18),
            const SizedBox(width: 6),
            Text(
              l10n.webviewVerifySuccess,
              style: const TextStyle(color: Colors.green),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          if (!_pageLoaded) ...[
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.webviewLoading,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ] else
            Text(
              l10n.webviewSearchingCookie,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          const Spacer(),
          TextButton(
            onPressed: _pageLoaded ? _closeWithCookieCheck : null,
            child: Text(l10n.webviewContinueManual),
          ),
        ],
      ),
    );
  }

  Future<void> _tryAutoClose() async {
    final cookies = await CookieManager.instance().getCookies(
      url: WebUri(widget.baseUrl),
    );
    
    if (cookies.isEmpty) return;
    
    final hasMultipleCookies = cookies.length >= 2;
    final hasLongCookie = cookies.any((c) => c.value.length > 50);
    final hasCfCookie = cookies.any(
      (c) => c.name == 'cf_clearance' || c.name == '__cf_bm',
    );
    
    if (hasCfCookie || (hasMultipleCookies && hasLongCookie)) {
      await _commitCookies(
        cookies.map((c) => '${c.name}=${c.value}').join('; '),
      );
    }
  }

  Future<void> _closeWithCookieCheck() async {
    final cookies = await CookieManager.instance().getCookies(
      url: WebUri(widget.baseUrl),
    );
    
    if (cookies.isNotEmpty) {
      await _commitCookies(
        cookies.map((c) => '${c.name}=${c.value}').join('; '),
      );
    } else {
      if (mounted) Navigator.of(context).pop(null);
    }
  }

  Future<void> _commitCookies(String cookieString) async {
    await WebCookieService.instance.saveCookies(widget.baseUrl, cookieString);
    if (!mounted) return;
    
    setState(() => _verified = true);
    await Future.delayed(const Duration(milliseconds: 600));
    
    if (mounted) Navigator.of(context).pop(cookieString);
  }
}

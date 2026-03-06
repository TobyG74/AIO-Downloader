import 'package:shared_preferences/shared_preferences.dart';

/// Service for storing cookies per domain.
class WebCookieService {
  static const _cookieExpiryHours = 1;

  static final WebCookieService instance = WebCookieService._();
  WebCookieService._();

  final Map<String, String> _cache = {};

  String _domainKey(String baseUrl) {
    final uri = Uri.tryParse(baseUrl);
    return uri?.host ?? baseUrl;
  }

  Future<String?> getCookies(String baseUrl) async {
    final key = _domainKey(baseUrl);
    
    if (_cache.containsKey(key)) {
      return _cache[key];
    }

    final prefs = await SharedPreferences.getInstance();
    final expiry = prefs.getInt('wcs_expiry_$key') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    if (now > expiry) {
      await _clearStored(key);
      return null;
    }
    
    final val = prefs.getString('wcs_cookies_$key');
    if (val != null) {
      _cache[key] = val;
    }
    return val;
  }

  Future<void> saveCookies(String baseUrl, String cookies) async {
    final key = _domainKey(baseUrl);
    _cache[key] = cookies;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wcs_cookies_$key', cookies);
    
    final expiry = DateTime.now().millisecondsSinceEpoch + 
                   (_cookieExpiryHours * 3600000);
    await prefs.setInt('wcs_expiry_$key', expiry);
  }

  Future<void> invalidate(String baseUrl) async {
    final key = _domainKey(baseUrl);
    _cache.remove(key);
    await _clearStored(key);
  }

  Future<void> _clearStored(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('wcs_cookies_$key');
    await prefs.remove('wcs_expiry_$key');
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import '../models/search_result_model.dart';

/// Service for searching locations using OSM Nominatim API
///
/// Provides location search functionality with:
/// - Auto-complete suggestions
/// - Debouncing for performance
/// - Error handling for network issues
/// - Result caching for better UX
///
/// OSM Nominatim API Documentation:
/// https://nominatim.org/release-docs/develop/api/Search/
///
/// Requirements: 9.2, 9.3, 9.4, 9.8, 9.9
class SearchService {
  // OSM Nominatim API base URL
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';
  
  // HTTP client for making requests
  final http.Client _client;
  
  // Cache for search results to improve performance
  final Map<String, List<SearchResultModel>> _cache = {};
  
  // Timer for debouncing search requests
  Timer? _debounceTimer;

  SearchService({http.Client? client}) : _client = client ?? http.Client();

  /// Search for locations using OSM Nominatim API
  ///
  /// Parameters:
  ///   - [query]: Search query string (minimum 3 characters)
  ///   - [limit]: Maximum number of results to return (default: 5)
  ///   - [countryCode]: Optional country code to limit results (e.g., 'id' for Indonesia)
  ///   - [viewbox]: Optional bounding box to prioritize results (format: 'minLon,minLat,maxLon,maxLat')
  ///
  /// Returns:
  ///   List of [SearchResultModel] containing location information
  ///
  /// Throws:
  ///   - [SearchException] if search fails
  ///   - [NetworkException] if network error occurs
  ///
  /// Example:
  /// ```dart
  /// final searchService = SearchService();
  /// try {
  ///   final results = await searchService.searchLocation(
  ///     'Mall Grand Indonesia',
  ///     countryCode: 'id',
  ///   );
  ///   for (final result in results) {
  ///     print('${result.displayName} at ${result.latitude}, ${result.longitude}');
  ///   }
  /// } catch (e) {
  ///   print('Search failed: $e');
  /// }
  /// ```
  ///
  /// Requirements: 9.3, 9.4, 9.8, 9.9
  Future<List<SearchResultModel>> searchLocation(
    String query, {
    int limit = 5,
    String? countryCode,
    String? viewbox,
  }) async {
    // Validate query length
    if (query.trim().length < 3) {
      return [];
    }

    // Check cache first
    final cacheKey = _getCacheKey(query, limit, countryCode, viewbox);
    if (_cache.containsKey(cacheKey)) {
      debugPrint('[SearchService] Returning cached results for: $query');
      return _cache[cacheKey]!;
    }

    debugPrint('[SearchService] Searching for: $query');

    try {
      // Build query parameters
      final queryParams = {
        'q': query.trim(),
        'format': 'json',
        'limit': limit.toString(),
        'addressdetails': '1',
        'accept-language': 'id', // Indonesian language for results
      };

      // Add optional parameters
      if (countryCode != null) {
        queryParams['countrycodes'] = countryCode;
      }
      if (viewbox != null) {
        queryParams['viewbox'] = viewbox;
        queryParams['bounded'] = '1'; // Restrict results to viewbox
      }

      // Build URI
      final uri = Uri.parse('$_baseUrl/search').replace(
        queryParameters: queryParams,
      );

      debugPrint('[SearchService] Request URL: $uri');

      // Make HTTP request with timeout
      final response = await _client.get(
        uri,
        headers: {
          'User-Agent': 'QParkin/1.0', // Required by Nominatim usage policy
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Search request timed out');
        },
      );

      debugPrint('[SearchService] Response status: ${response.statusCode}');

      // Check response status
      if (response.statusCode == 200) {
        // Parse JSON response
        final List<dynamic> jsonData = json.decode(response.body);
        
        debugPrint('[SearchService] Found ${jsonData.length} results');

        // Convert to SearchResultModel list
        final results = jsonData
            .map((json) => SearchResultModel.fromJson(json))
            .toList();

        // Cache results
        _cache[cacheKey] = results;

        return results;
      } else if (response.statusCode == 429) {
        // Rate limit exceeded
        throw SearchException(
          'Terlalu banyak permintaan. Silakan coba lagi nanti.',
        );
      } else {
        throw SearchException(
          'Pencarian gagal dengan kode: ${response.statusCode}',
        );
      }
    } on TimeoutException catch (e) {
      debugPrint('[SearchService] Timeout error: $e');
      throw NetworkException(
        'Koneksi timeout. Periksa koneksi internet Anda.',
      );
    } on http.ClientException catch (e) {
      debugPrint('[SearchService] Network error: $e');
      throw NetworkException(
        'Koneksi internet bermasalah. Periksa koneksi Anda.',
      );
    } catch (e) {
      debugPrint('[SearchService] Unexpected error: $e');
      if (e is SearchException || e is NetworkException) {
        rethrow;
      }
      throw SearchException(
        'Terjadi kesalahan saat mencari lokasi: ${e.toString()}',
      );
    }
  }

  /// Search with debouncing to avoid excessive API calls
  ///
  /// Delays the search request until the user stops typing for the specified duration.
  /// Cancels previous pending requests when new input is received.
  ///
  /// Parameters:
  ///   - [query]: Search query string
  ///   - [onResults]: Callback function to receive search results
  ///   - [onError]: Callback function to handle errors
  ///   - [debounceDuration]: Duration to wait before triggering search (default: 500ms)
  ///   - [limit]: Maximum number of results
  ///   - [countryCode]: Optional country code filter
  ///   - [viewbox]: Optional bounding box filter
  ///
  /// Example:
  /// ```dart
  /// final searchService = SearchService();
  /// searchService.searchWithDebounce(
  ///   'Mall',
  ///   onResults: (results) {
  ///     setState(() {
  ///       searchResults = results;
  ///     });
  ///   },
  ///   onError: (error) {
  ///     print('Search error: $error');
  ///   },
  /// );
  /// ```
  ///
  /// Requirements: 9.2
  void searchWithDebounce(
    String query, {
    required Function(List<SearchResultModel>) onResults,
    required Function(String) onError,
    Duration debounceDuration = const Duration(milliseconds: 500),
    int limit = 5,
    String? countryCode,
    String? viewbox,
  }) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Return empty results for short queries
    if (query.trim().length < 3) {
      onResults([]);
      return;
    }

    // Set new timer
    _debounceTimer = Timer(debounceDuration, () async {
      try {
        final results = await searchLocation(
          query,
          limit: limit,
          countryCode: countryCode,
          viewbox: viewbox,
        );
        onResults(results);
      } on SearchException catch (e) {
        onError(e.message);
      } on NetworkException catch (e) {
        onError(e.message);
      } catch (e) {
        onError('Terjadi kesalahan: ${e.toString()}');
      }
    });
  }

  /// Generate cache key for search results
  String _getCacheKey(String query, int limit, String? countryCode, String? viewbox) {
    return '$query|$limit|${countryCode ?? ''}|${viewbox ?? ''}';
  }

  /// Clear search cache
  void clearCache() {
    _cache.clear();
    debugPrint('[SearchService] Cache cleared');
  }

  /// Cancel any pending debounced search
  void cancelPendingSearch() {
    _debounceTimer?.cancel();
    debugPrint('[SearchService] Pending search cancelled');
  }

  /// Dispose resources
  void dispose() {
    _debounceTimer?.cancel();
    _client.close();
  }
}

/// Exception thrown when search operation fails
class SearchException implements Exception {
  final String message;

  SearchException(this.message);

  @override
  String toString() => 'SearchException: $message';
}

/// Exception thrown when network error occurs
class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

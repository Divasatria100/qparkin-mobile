import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../data/models/booking_model.dart';
import '../../logic/providers/active_parking_provider.dart';
import '../dialogs/booking_confirmation_dialog.dart';
import 'booking_detail_page.dart';

/// Midtrans Snap Payment Page using WebView
/// 
/// Displays official Midtrans Snap payment page
/// Handles payment callbacks (success, pending, error)
class MidtransPaymentPage extends StatefulWidget {
  final BookingModel booking;

  const MidtransPaymentPage({
    Key? key,
    required this.booking,
  }) : super(key: key);

  @override
  State<MidtransPaymentPage> createState() => _MidtransPaymentPageState();
}

class _MidtransPaymentPageState extends State<MidtransPaymentPage> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _snapToken;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _getSnapToken();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('[MidtransPayment] Page started: $url');
            _handleNavigationUrl(url);
          },
          onPageFinished: (String url) {
            debugPrint('[MidtransPayment] Page finished: $url');
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('[MidtransPayment] Error: ${error.description}');
            setState(() {
              _errorMessage = 'Gagal memuat halaman pembayaran';
              _isLoading = false;
            });
          },
        ),
      );
  }

  /// Get Snap Token from backend
  Future<void> _getSnapToken() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      const baseUrl = String.fromEnvironment(
        'API_URL',
        defaultValue: 'http://localhost:8000',
      );

      debugPrint('[MidtransPayment] Requesting snap token for booking: ${widget.booking.idBooking}');

      final response = await http.post(
        Uri.parse('$baseUrl/api/bookings/${widget.booking.idBooking}/payment/snap-token'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      debugPrint('[MidtransPayment] Response status: ${response.statusCode}');
      debugPrint('[MidtransPayment] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Backend returns snap_token at root level, not nested in 'data'
        final snapToken = data['snap_token'];
        
        if (snapToken == null || snapToken.isEmpty) {
          throw Exception('Snap token tidak valid');
        }

        setState(() {
          _snapToken = snapToken;
        });

        // Load Midtrans Snap page
        _loadSnapPage(snapToken);
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Gagal mendapatkan snap token');
      }
    } catch (e) {
      debugPrint('[MidtransPayment] Error getting snap token: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Load Midtrans Snap payment page
  void _loadSnapPage(String snapToken) {
    // Midtrans Snap URL (Sandbox or Production)
    // For sandbox: https://app.sandbox.midtrans.com/snap/v2/vtweb/{snap_token}
    // For production: https://app.midtrans.com/snap/v2/vtweb/{snap_token}
    
    const isSandbox = true; // Change to false for production
    final snapUrl = isSandbox
        ? 'https://app.sandbox.midtrans.com/snap/v2/vtweb/$snapToken'
        : 'https://app.midtrans.com/snap/v2/vtweb/$snapToken';

    debugPrint('[MidtransPayment] Loading Snap URL: $snapUrl');

    _controller.loadRequest(Uri.parse(snapUrl));
  }

  /// Handle navigation URL for payment callbacks
  void _handleNavigationUrl(String url) {
    debugPrint('[MidtransPayment] Handling URL: $url');

    // Handle Midtrans simulator deeplink (payment success)
    if (url.contains('simulator.sandbox.midtrans.com') && url.contains('deeplink/payment')) {
      debugPrint('[MidtransPayment] Detected Midtrans simulator success');
      // Simulator always means success in sandbox
      _handlePaymentSuccess();
      return;
    }

    // Check for finish redirect URL from Midtrans
    // Midtrans will redirect to finish_url with query parameters
    if (url.contains('finish') || url.contains('status_code')) {
      final uri = Uri.parse(url);
      final statusCode = uri.queryParameters['status_code'];
      final transactionStatus = uri.queryParameters['transaction_status'];

      debugPrint('[MidtransPayment] Status code: $statusCode');
      debugPrint('[MidtransPayment] Transaction status: $transactionStatus');

      // Handle payment result
      if (statusCode == '200' || transactionStatus == 'settlement' || transactionStatus == 'capture') {
        _handlePaymentSuccess();
      } else if (transactionStatus == 'pending') {
        _handlePaymentPending();
      } else if (transactionStatus == 'deny' || transactionStatus == 'cancel' || transactionStatus == 'expire') {
        _handlePaymentFailed(transactionStatus ?? 'failed');
      }
    }
  }

  /// Handle successful payment
  Future<void> _handlePaymentSuccess() async {
    debugPrint('[MidtransPayment] Payment successful');

    try {
      // Update booking status to PAID
      await _updateBookingStatus('PAID');

      if (!mounted) return;

      // Clear and refresh active parking data
      final activeParkingProvider = Provider.of<ActiveParkingProvider>(
        context,
        listen: false,
      );
      
      // Clear old data first
      activeParkingProvider.clear();
      
      // Wait a bit for backend to process
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Fetch fresh data
      final token = await _storage.read(key: 'auth_token');
      if (token != null) {
        debugPrint('[MidtransPayment] Refreshing active parking data...');
        await activeParkingProvider.fetchActiveParking(token: token);
        debugPrint('[MidtransPayment] Active parking refreshed: ${activeParkingProvider.hasActiveParking}');
      }

      // Navigate to confirmation dialog
      _showSuccessDialog();
    } catch (e) {
      debugPrint('[MidtransPayment] Error handling success: $e');
      _showErrorDialog('Pembayaran berhasil, tetapi gagal memperbarui status booking');
    }
  }

  /// Handle pending payment
  void _handlePaymentPending() {
    debugPrint('[MidtransPayment] Payment pending');

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Pembayaran Pending'),
        content: const Text(
          'Pembayaran Anda sedang diproses. '
          'Kami akan memberitahu Anda setelah pembayaran dikonfirmasi.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close payment page
              Navigator.pushReplacementNamed(context, '/activity');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Handle failed payment
  void _handlePaymentFailed(String reason) {
    debugPrint('[MidtransPayment] Payment failed: $reason');

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pembayaran Gagal'),
        content: Text(
          'Pembayaran Anda gagal atau dibatalkan.\n\n'
          'Alasan: ${_getFailureReason(reason)}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close payment page
            },
            child: const Text('Kembali'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Retry payment by reloading snap page
              setState(() {
                _isLoading = true;
              });
              _getSnapToken();
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  String _getFailureReason(String status) {
    switch (status) {
      case 'deny':
        return 'Pembayaran ditolak oleh bank';
      case 'cancel':
        return 'Pembayaran dibatalkan';
      case 'expire':
        return 'Pembayaran kadaluarsa';
      default:
        return 'Pembayaran gagal';
    }
  }

  /// Update booking status in backend
  Future<void> _updateBookingStatus(String status) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) return;

      const baseUrl = String.fromEnvironment(
        'API_URL',
        defaultValue: 'http://localhost:8000',
      );

      final response = await http.put(
        Uri.parse('$baseUrl/api/bookings/${widget.booking.idBooking}/payment/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'payment_status': status,
        }),
      );

      debugPrint('[MidtransPayment] Update status response: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('Gagal memperbarui status booking');
      }
    } catch (e) {
      debugPrint('[MidtransPayment] Error updating status: $e');
      rethrow;
    }
  }

  /// Show success dialog and navigate to booking detail page
  void _showSuccessDialog() {
    // Pop payment page
    Navigator.pop(context);

    // Navigate directly to booking detail page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BookingDetailPage(
          booking: widget.booking.copyWith(status: 'aktif'),
        ),
      ),
    );
  }

  /// Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close payment page
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: const Color(0xFF6B4CE6),
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_isLoading) {
      return _buildLoadingState();
    }

    return WebViewWidget(controller: _controller);
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Memuat halaman pembayaran...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Gagal Memuat Pembayaran',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                  _isLoading = true;
                });
                _getSnapToken();
              },
              child: const Text('Coba Lagi'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logic/providers/point_provider.dart';
import '../../data/services/auth_service.dart';
import '../../utils/responsive_helper.dart';
import '../../utils/point_error_handler.dart';
import '../widgets/point_balance_card.dart';
import '../widgets/point_history_item.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/point_info_bottom_sheet.dart';
import '../widgets/point_empty_state.dart';

class PointPage extends StatefulWidget {
  const PointPage({super.key});

  @override
  State<PointPage> createState() => _PointPageState();
}

class _PointPageState extends State<PointPage>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _historyScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final p = context.read<PointProvider>();
      
      // Get token from auth service
      final authService = AuthService();
      final token = await authService.getToken();
      
      if (token != null) {
        // Try to fetch from API
        p.fetchBalance(token: token);
        p.fetchHistory(token: token);
      }
      
      // Load test data for development (remove in production)
      _loadTestDataIfNeeded();
    });

    _historyScrollController.addListener(_onHistoryScroll);
  }

  /// Load test data if API returns empty
  /// This is for development/testing purposes only
  void _loadTestDataIfNeeded() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      
      final provider = context.read<PointProvider>();
      
      // If no data from API, use test data
      if (provider.filteredHistory.isEmpty) {
        debugPrint('[PointPage] No data from API, consider adding test data');
        // Test data loading can be implemented if needed
      }
    });
  }

  @override
  void dispose() {
    _historyScrollController.removeListener(_onHistoryScroll);
    _historyScrollController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _handleRefresh() async {
    final provider = context.read<PointProvider>();
    final authService = AuthService();
    final token = await authService.getToken();
    
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesi login telah berakhir'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    
    try {
      await provider.refresh(token: token);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil diperbarui'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = PointErrorHandler.getUserFriendlyMessage(e);
        final requiresInternet = PointErrorHandler.requiresInternetMessage(e);
        PointErrorHandler.logError(e, context: 'handleRefresh');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(requiresInternet
                ? 'Memerlukan koneksi internet. Periksa koneksi Anda.'
                : errorMessage),
            duration: const Duration(seconds: 3),
            backgroundColor: const Color.fromRGBO(87, 62, 209, 1),
            action: SnackBarAction(
              label: 'Coba Lagi',
              textColor: Colors.white,
              onPressed: _handleRefresh,
            ),
          ),
        );
      }
    }
  }

  void _onHistoryScroll() {
    if (!_historyScrollController.hasClients) return;
    final provider = context.read<PointProvider>();
    final maxScroll = _historyScrollController.position.maxScrollExtent;
    final current = _historyScrollController.position.pixels;

    if (maxScroll <= 0) return;

    if (current >= maxScroll * 0.9) {
      if (!provider.isLoadingMore && provider.hasMorePages) {
        Future.delayed(const Duration(milliseconds: 300), () async {
          if (mounted &&
              !provider.isLoadingMore &&
              provider.hasMorePages) {
            final authService = AuthService();
            final token = await authService.getToken();
            if (token != null) {
              provider.fetchHistory(token: token, loadMore: true);
            }
          }
        });
      }
    }
  }

  void _showFilterBottomSheet() {
    final provider = context.read<PointProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        currentFilter: provider.currentFilter,
        onApply: (filter) => provider.applyFilter(filter),
      ),
    );
  }

  void _showPointInfoBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PointInfoBottomSheet(),
    );
  }

  Widget _buildOfflineIndicator(PointProvider provider) {
    return Semantics(
      label: 'Peringatan: Data mungkin tidak terkini',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.orange[100],
          border: Border(
            bottom: BorderSide(
              color: Colors.orange[300]!,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange[800],
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Data mungkin tidak terkini. Tarik untuk refresh.',
                style: TextStyle(
                  color: Colors.orange[900],
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Poin Saya'),
        backgroundColor: const Color.fromRGBO(87, 62, 209, 1),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Info Poin',
            onPressed: _showPointInfoBottomSheet,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Consumer<PointProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: _handleRefresh,
            color: const Color.fromRGBO(87, 62, 209, 1),
            child: CustomScrollView(
              controller: _historyScrollController,
              slivers: [
                // Offline Indicator
                if (provider.isOffline)
                  SliverToBoxAdapter(
                    child: _buildOfflineIndicator(provider),
                  ),

                // Balance Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                    child: PointBalanceCard(
                      balance: provider.balance,
                      equivalentValue: provider.equivalentValue,
                      isLoading: provider.isLoading,
                    ),
                  ),
                ),

                // History Section Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 24.0 : 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Riwayat Poin',
                          style: TextStyle(
                            fontSize: isTablet ? 20 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (provider.currentFilter.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(87, 62, 209, 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Filter Aktif',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color.fromRGBO(87, 62, 209, 1),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // History List
                if (provider.isLoading && provider.filteredHistory.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: const Color.fromRGBO(87, 62, 209, 1),
                      ),
                    ),
                  )
                else if (provider.filteredHistory.isEmpty)
                  const SliverFillRemaining(
                    child: PointEmptyState(),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 24.0 : 16.0,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index < provider.filteredHistory.length) {
                            return PointHistoryItem(
                              history: provider.filteredHistory[index],
                            );
                          } else if (provider.isLoadingMore) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: const Color.fromRGBO(87, 62, 209, 1),
                                ),
                              ),
                            );
                          } else if (!provider.hasMorePages) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: Text(
                                  'Tidak ada riwayat lagi',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        childCount: provider.filteredHistory.length + 1,
                      ),
                    ),
                  ),

                // Bottom Spacing
                const SliverToBoxAdapter(
                  child: SizedBox(height: 16),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
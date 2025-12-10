import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../logic/providers/point_provider.dart';
import '../../data/models/point_filter_model.dart';
import '../../data/models/point_statistics_model.dart';
import '../../utils/responsive_helper.dart';
import '../../utils/point_error_handler.dart';
import '../widgets/point_balance_card.dart';
import '../widgets/point_statistics_card.dart';
import '../widgets/point_history_item.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/point_info_bottom_sheet.dart';
import '../widgets/point_empty_state.dart';

/// Data class for overview tab to optimize rebuilds
class _OverviewData {
  final int? balance;
  final bool isLoadingBalance;
  final String? balanceError;
  final PointStatistics? statistics;
  final bool isLoadingStatistics;
  final String? statisticsError;

  _OverviewData({
    required this.balance,
    required this.isLoadingBalance,
    required this.balanceError,
    required this.statistics,
    required this.isLoadingStatistics,
    required this.statisticsError,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _OverviewData &&
          runtimeType == other.runtimeType &&
          balance == other.balance &&
          isLoadingBalance == other.isLoadingBalance &&
          balanceError == other.balanceError &&
          statistics == other.statistics &&
          isLoadingStatistics == other.isLoadingStatistics &&
          statisticsError == other.statisticsError;

  @override
  int get hashCode =>
      balance.hashCode ^
      isLoadingBalance.hashCode ^
      balanceError.hashCode ^
      statistics.hashCode ^
      isLoadingStatistics.hashCode ^
      statisticsError.hashCode;
}

/// Point Page - Main screen for point management
///
/// Displays:
/// - Point balance with loading/error states
/// - Statistics overview
/// - Point history with filtering
/// - Pull-to-refresh functionality
/// - Auto-sync on page resume
///
/// Performance optimizations:
/// - Uses Selector instead of Consumer to reduce unnecessary rebuilds
/// - ListView.builder with optimized settings for efficient rendering
/// - RepaintBoundary to isolate widget repaints
/// - Debounced scroll listener for pagination
///
/// Requirements: 1.1, 1.3, 1.4, 2.1, 5.1, 8.1, 8.2, 8.3, 8.4, 8.5, 10.1, 10.2, 10.3, 10.4
class PointPage extends StatefulWidget {
  const PointPage({super.key});

  @override
  State<PointPage> createState() => _PointPageState();
}

class _PointPageState extends State<PointPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  final ScrollController _historyScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Auto-sync on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoSyncData();
      // Mark notifications as read when page is opened
      _markNotificationsAsRead();
    });

    // Setup infinite scroll for history
    _historyScrollController.addListener(_onHistoryScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _historyScrollController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  /// Auto-sync data if last sync was more than 30 seconds ago
  /// Also invalidates stale cache and attempts connection restoration
  ///
  /// Requirements: 8.4, 10.4
  Future<void> _autoSyncData() async {
    final provider = context.read<PointProvider>();
    
    // Invalidate stale cache first
    await provider.invalidateStaleCache();
    
    // Attempt to sync if offline
    if (provider.isOffline) {
      await provider.syncOnConnectionRestored();
    } else {
      // Normal auto-sync
      await provider.autoSync();
    }
  }

  /// Mark notifications as read when page is opened
  ///
  /// Requirements: 7.5
  void _markNotificationsAsRead() {
    final provider = context.read<PointProvider>();
    provider.markNotificationsAsRead();
  }

  /// Handle pull-to-refresh
  ///
  /// Requirements: 8.1, 8.2
  Future<void> _handleRefresh() async {
    final provider = context.read<PointProvider>();

    try {
      await provider.refreshAll();

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
        // Get user-friendly error message
        final errorMessage = PointErrorHandler.getUserFriendlyMessage(e);
        final requiresInternet = PointErrorHandler.requiresInternetMessage(e);
        
        // Log error for debugging
        PointErrorHandler.logError(e, context: 'handleRefresh');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              requiresInternet 
                ? 'Memerlukan koneksi internet. Periksa koneksi Anda.'
                : errorMessage
            ),
            duration: const Duration(seconds: 3),
            backgroundColor: AppTheme.brandRed,
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

  /// Handle infinite scroll for history with debouncing
  /// Prevents multiple rapid calls during fast scrolling
  void _onHistoryScroll() {
    if (_historyScrollController.position.pixels >=
        _historyScrollController.position.maxScrollExtent * 0.9) {
      // Load more when 90% scrolled
      final provider = context.read<PointProvider>();
      if (!provider.isLoadingHistory && provider.hasMoreHistory) {
        // Debounce to prevent multiple rapid calls
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && !provider.isLoadingHistory && provider.hasMoreHistory) {
            provider.fetchHistory(loadMore: true);
          }
        });
      }
    }
  }

  /// Show filter bottom sheet
  ///
  /// Requirements: 3.1
  void _showFilterBottomSheet() {
    final provider = context.read<PointProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        currentFilter: provider.currentFilter,
        onApply: (filter) {
          provider.setFilter(filter);
        },
      ),
    );
  }

  /// Show point info bottom sheet
  ///
  /// Requirements: 5.1
  void _showPointInfoBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PointInfoBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Offline indicator banner
          Consumer<PointProvider>(
            builder: (context, provider, child) {
              if (provider.isUsingCachedData || provider.isOffline) {
                return _buildOfflineIndicator(provider);
              }
              return const SizedBox.shrink();
            },
          ),
          
          // Main content
          Expanded(
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  _buildAppBar(innerBoxIsScrolled),
                ];
              },
              body: _buildBody(),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Build app bar with gradient background
  /// Responsive to orientation and screen size
  Widget _buildAppBar(bool innerBoxIsScrolled) {
    final expandedHeight = ResponsiveHelper.getAppBarHeight(context);
    final isLandscape = ResponsiveHelper.isLandscape(context);
    final topPadding = isLandscape ? 40.0 : 60.0;
    
    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.brandIndigo,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Poin Saya',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: innerBoxIsScrolled ? 18 : 20,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.heroGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, topPadding, 16, 16),
              child: Consumer<PointProvider>(
                builder: (context, provider, child) {
                  return PointBalanceCard(
                    balance: provider.balance,
                    isLoading: provider.isLoadingBalance,
                    error: provider.balanceError,
                    onRetry: () => provider.fetchBalance(),
                  );
                },
              ),
            ),
          ),
        ),
      ),
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        tabs: [
          Semantics(
            label: 'Tab ringkasan poin',
            hint: 'Menampilkan saldo dan statistik poin',
            child: const Tab(text: 'Ringkasan'),
          ),
          Semantics(
            label: 'Tab riwayat poin',
            hint: 'Menampilkan riwayat transaksi poin',
            child: const Tab(text: 'Riwayat'),
          ),
        ],
      ),
    );
  }

  /// Build main body with tabs
  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppTheme.brandIndigo,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  /// Build Overview tab
  /// Responsive layout for different screen sizes and orientations
  /// Optimized with selective Consumer to reduce unnecessary rebuilds
  ///
  /// Requirements: 1.1, 1.2, 4.1, 9.1
  Widget _buildOverviewTab() {
    // Use Selector instead of Consumer to only rebuild when specific data changes
    return Selector<PointProvider, _OverviewData>(
      selector: (context, provider) => _OverviewData(
        balance: provider.balance,
        isLoadingBalance: provider.isLoadingBalance,
        balanceError: provider.balanceError,
        statistics: provider.statistics,
        isLoadingStatistics: provider.isLoadingStatistics,
        statisticsError: provider.statisticsError,
      ),
      builder: (context, data, child) {
        final padding = ResponsiveHelper.getResponsivePadding(context);
        final spacing = ResponsiveHelper.getOrientationAwareSpacing(context, 16.0);
        final isLandscape = ResponsiveHelper.isLandscape(context);
        
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(padding),
          child: isLandscape && ResponsiveHelper.isTablet(context)
              ? _buildLandscapeLayout(data, spacing)
              : _buildPortraitLayout(data, spacing),
        );
      },
    );
  }
  
  /// Build portrait layout (default)
  Widget _buildPortraitLayout(_OverviewData data, double spacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Point Balance Card at top
        PointBalanceCard(
          balance: data.balance,
          isLoading: data.isLoadingBalance,
          error: data.balanceError,
          onRetry: () => context.read<PointProvider>().fetchBalance(),
        ),
        SizedBox(height: spacing),

        // Statistics Card
        PointStatisticsCard(
          statistics: data.statistics,
          isLoading: data.isLoadingStatistics,
        ),
        SizedBox(height: spacing),

        // View History Button
        _buildViewHistoryButton(),

        // Error state for statistics
        if (data.statisticsError != null) ...[
          SizedBox(height: spacing),
          _buildErrorCard(
            message: data.statisticsError!,
            onRetry: () => context.read<PointProvider>().fetchStatistics(),
          ),
        ],
      ],
    );
  }
  
  /// Build landscape layout for tablets (side-by-side)
  Widget _buildLandscapeLayout(_OverviewData data, double spacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side: Balance card
            Expanded(
              flex: 1,
              child: PointBalanceCard(
                balance: data.balance,
                isLoading: data.isLoadingBalance,
                error: data.balanceError,
                onRetry: () => context.read<PointProvider>().fetchBalance(),
              ),
            ),
            SizedBox(width: spacing),
            
            // Right side: Statistics card
            Expanded(
              flex: 1,
              child: PointStatisticsCard(
                statistics: data.statistics,
                isLoading: data.isLoadingStatistics,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing),

        // View History Button
        _buildViewHistoryButton(),

        // Error state for statistics
        if (data.statisticsError != null) ...[
          SizedBox(height: spacing),
          _buildErrorCard(
            message: data.statisticsError!,
            onRetry: () => context.read<PointProvider>().fetchStatistics(),
          ),
        ],
      ],
    );
  }
  
  /// Build view history button
  Widget _buildViewHistoryButton() {
    return Semantics(
      button: true,
      label: 'Tombol lihat riwayat lengkap',
      hint: 'Ketuk untuk melihat riwayat poin lengkap',
      child: ElevatedButton.icon(
        onPressed: () {
          _tabController.animateTo(1);
        },
        icon: const Icon(Icons.history, size: 20),
        label: const Text('Lihat Riwayat Lengkap'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.brandIndigo,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  /// Build History tab
  ///
  /// Requirements: 2.1, 2.2, 2.5, 2.6, 3.1, 3.5
  Widget _buildHistoryTab() {
    return Consumer<PointProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Filter section
            _buildFilterSection(provider),

            // History list
            Expanded(
              child: _buildHistoryList(provider),
            ),
          ],
        );
      },
    );
  }

  /// Build filter section with chips
  ///
  /// Requirements: 3.1, 3.5
  Widget _buildFilterSection(PointProvider provider) {
    final hasActiveFilter = provider.currentFilter.type != PointFilterType.all ||
        provider.currentFilter.period != PointFilterPeriod.allTime;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Filter button
                  Semantics(
                    button: true,
                    label: 'Tombol filter',
                    hint: 'Ketuk untuk membuka opsi filter',
                    child: InkWell(
                      onTap: _showFilterBottomSheet,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: hasActiveFilter
                              ? AppTheme.brandIndigo
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: hasActiveFilter
                                ? AppTheme.brandIndigo
                                : Colors.grey[300]!,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.filter_list,
                              size: 18,
                              color: hasActiveFilter ? Colors.white : Colors.black87,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Filter',
                              style: TextStyle(
                                color: hasActiveFilter ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            if (hasActiveFilter) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '1',
                                  style: TextStyle(
                                    color: AppTheme.brandIndigo,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Active filter display
                  if (hasActiveFilter) ...[
                    const SizedBox(width: 8),
                    Semantics(
                      label: 'Filter aktif: ${provider.currentFilter.displayText}',
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ExcludeSemantics(
                              child: Text(
                                provider.currentFilter.displayText,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Semantics(
                              button: true,
                              label: 'Hapus filter',
                              hint: 'Ketuk untuk menghapus filter',
                              child: InkWell(
                                onTap: () {
                                  provider.setFilter(PointFilter.all());
                                },
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minWidth: 24,
                                    minHeight: 24,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build history list with loading, error, and empty states
  ///
  /// Requirements: 2.1, 2.2, 2.6, 10.1, 10.2
  /// Optimized with ListView.builder for efficient rendering
  Widget _buildHistoryList(PointProvider provider) {
    // Loading state (initial load)
    if (provider.isLoadingHistory && provider.history.isEmpty) {
      return _buildLoadingState();
    }

    // Error state
    if (provider.historyError != null && provider.history.isEmpty) {
      return _buildErrorState(
        message: provider.historyError!,
        onRetry: () => provider.fetchHistory(),
      );
    }

    // Empty state (no history or filtered results)
    final filteredHistory = provider.filteredHistory;
    if (filteredHistory.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: const PointEmptyState(),
        ),
      );
    }

    // History list - optimized with ListView.builder
    // Uses addAutomaticKeepAlives: false to reduce memory usage
    // Uses addRepaintBoundaries: true to optimize repaints
    return ListView.builder(
      controller: _historyScrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: filteredHistory.length + (provider.isLoadingHistory ? 1 : 0),
      addAutomaticKeepAlives: false, // Reduce memory for off-screen items
      addRepaintBoundaries: true, // Optimize repaints
      cacheExtent: 500, // Cache 500 pixels ahead for smooth scrolling
      itemBuilder: (context, index) {
        // Loading indicator at bottom
        if (index == filteredHistory.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final history = filteredHistory[index];

        // Use RepaintBoundary to isolate repaints to individual items
        return RepaintBoundary(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: PointHistoryItem(
                history: history,
                onTap: history.hasTransaction
                    ? () {
                        // TODO: Navigate to transaction details
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Detail transaksi akan ditampilkan'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return Semantics(
      label: 'Memuat riwayat poin',
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  /// Build error state with retry button
  ///
  /// Requirements: 10.2, 10.3
  Widget _buildErrorState({
    required String message,
    required VoidCallback onRetry,
  }) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Semantics(
        label: 'Terjadi kesalahan. $message',
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ExcludeSemantics(
                  child: Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.brandRed,
                  ),
                ),
                const SizedBox(height: 16),
                const ExcludeSemantics(
                  child: Text(
                    'Terjadi Kesalahan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ExcludeSemantics(
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                Semantics(
                  button: true,
                  label: 'Tombol coba lagi',
                  hint: 'Ketuk untuk mencoba memuat ulang data',
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: 20),
                    label: const Text('Coba Lagi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.brandIndigo,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build error card for inline errors
  Widget _buildErrorCard({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Semantics(
      label: 'Peringatan error. $message',
      child: Card(
        elevation: 0,
        color: AppTheme.brandRed.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppTheme.brandRed.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ExcludeSemantics(
                child: Icon(
                  Icons.error_outline,
                  color: AppTheme.brandRed,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ExcludeSemantics(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.brandRed,
                    ),
                  ),
                ),
              ),
              Semantics(
                button: true,
                label: 'Tombol coba lagi',
                hint: 'Ketuk untuk mencoba memuat ulang',
                child: TextButton(
                  onPressed: onRetry,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(48, 48),
                  ),
                  child: const Text('Coba Lagi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build offline indicator banner
  ///
  /// Requirements: 10.1, 10.2
  Widget _buildOfflineIndicator(PointProvider provider) {
    return Semantics(
      label: 'Peringatan: Data mungkin tidak terkini',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            ExcludeSemantics(
              child: Icon(
                Icons.cloud_off,
                size: 20,
                color: Colors.orange[900],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ExcludeSemantics(
                child: Text(
                  'Data mungkin tidak terkini',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange[900],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            if (provider.lastSyncTime != null) ...[
              ExcludeSemantics(
                child: Text(
                  _formatLastSyncTime(provider.lastSyncTime!),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[800],
                  ),
                ),
              ),
            ],
            const SizedBox(width: 8),
            Semantics(
              button: true,
              label: 'Tombol coba sinkronisasi',
              hint: 'Ketuk untuk mencoba menyinkronkan data dengan server',
              child: InkWell(
                onTap: () async {
                  await provider.syncOnConnectionRestored();
                },
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.refresh,
                    size: 20,
                    color: Colors.orange[900],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Format last sync time for display
  String _formatLastSyncTime(DateTime lastSync) {
    final now = DateTime.now();
    final difference = now.difference(lastSync);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}j lalu';
    } else {
      return '${difference.inDays}h lalu';
    }
  }

  /// Build floating action button for "Cara Kerja Poin"
  ///
  /// Requirements: 5.1
  Widget _buildFloatingActionButton() {
    return Semantics(
      button: true,
      label: 'Cara kerja poin',
      hint: 'Ketuk untuk melihat informasi cara kerja sistem poin',
      child: FloatingActionButton.extended(
        onPressed: _showPointInfoBottomSheet,
        backgroundColor: AppTheme.brandIndigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.help_outline),
        label: const Text(
          'Cara Kerja Poin',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 4,
      ),
    );
  }
}

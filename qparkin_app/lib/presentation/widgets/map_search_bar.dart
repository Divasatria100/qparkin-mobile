import 'package:flutter/material.dart';
import '../../data/models/search_result_model.dart';

/// Search bar widget for map location search
///
/// Features:
/// - Auto-complete with debouncing (500ms)
/// - Dropdown suggestions
/// - Clear button
/// - Loading indicator
/// - Error handling
///
/// Requirements: 9.1, 9.2, 9.5, 9.6, 9.7
class MapSearchBar extends StatefulWidget {
  /// Callback when search query changes (with debouncing)
  final Function(String) onSearchChanged;

  /// Callback when a search result is selected
  final Function(SearchResultModel) onResultSelected;

  /// Current search results to display
  final List<SearchResultModel> searchResults;

  /// Whether search is in progress
  final bool isSearching;

  /// Error message to display (if any)
  final String? errorMessage;

  const MapSearchBar({
    Key? key,
    required this.onSearchChanged,
    required this.onResultSelected,
    required this.searchResults,
    this.isSearching = false,
    this.errorMessage,
  }) : super(key: key);

  @override
  State<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    
    // Listen to focus changes
    _focusNode.addListener(() {
      setState(() {
        _showSuggestions = _focusNode.hasFocus && 
                          _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _showSuggestions = false;
    });
    widget.onSearchChanged('');
    _focusNode.unfocus();
  }

  void _handleResultTap(SearchResultModel result) {
    _searchController.text = result.shortName;
    setState(() {
      _showSuggestions = false;
    });
    _focusNode.unfocus();
    widget.onResultSelected(result);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'Cari lokasi...',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey.shade600,
                size: 24,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Loading indicator
                  if (widget.isSearching)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF573ED1),
                          ),
                        ),
                      ),
                    ),
                  
                  // Clear button
                  if (_searchController.text.isNotEmpty && !widget.isSearching)
                    IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                      onPressed: _clearSearch,
                      tooltip: 'Hapus',
                    ),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            onChanged: (value) {
              setState(() {
                _showSuggestions = value.isNotEmpty;
              });
              widget.onSearchChanged(value);
            },
            onSubmitted: (value) {
              // If there's exactly one result, select it
              if (widget.searchResults.length == 1) {
                _handleResultTap(widget.searchResults.first);
              }
            },
          ),
        ),

        // Suggestions dropdown
        if (_showSuggestions && 
            (_searchController.text.length >= 3 || 
             widget.errorMessage != null))
          const SizedBox(height: 8),

        if (_showSuggestions && _searchController.text.length >= 3)
          _buildSuggestionsDropdown(),
      ],
    );
  }

  Widget _buildSuggestionsDropdown() {
    return Container(
      constraints: const BoxConstraints(
        maxHeight: 300,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildSuggestionsContent(),
    );
  }

  Widget _buildSuggestionsContent() {
    // Show error message
    if (widget.errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.shade400,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.errorMessage!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red.shade700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Show loading state
    if (widget.isSearching) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF573ED1)),
          ),
        ),
      );
    }

    // Show "no results" message
    if (widget.searchResults.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.search_off,
              color: Colors.grey.shade400,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Lokasi tidak ditemukan',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Show search results
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: widget.searchResults.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: Colors.grey.shade200,
      ),
      itemBuilder: (context, index) {
        final result = widget.searchResults[index];
        return _buildSuggestionItem(result);
      },
    );
  }

  Widget _buildSuggestionItem(SearchResultModel result) {
    return InkWell(
      onTap: () => _handleResultTap(result),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          children: [
            // Location icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF573ED1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.location_on,
                color: Color(0xFF573ED1),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Location details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location name
                  Text(
                    result.shortName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Address
                  Text(
                    result.addressWithoutName.isNotEmpty
                        ? result.addressWithoutName
                        : result.displayName,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Arrow icon
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_theme.dart';
import '../data/models/user_model.dart';
import '../data/services/user_service.dart';

class ThirdScreen extends StatefulWidget {
  const ThirdScreen({super.key});

  @override
  State<ThirdScreen> createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  final UserService _userService = UserService();
  final ScrollController _scrollController = ScrollController();

  final List<User> _users = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _isFirstLoad = true;
  bool _hasMore = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _fetchUsers();
      }
    }
  }

  Future<void> _fetchUsers() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _userService.getUsers(page: _currentPage);
      setState(() {
        _users.addAll(response.data);
        _hasMore = response.hasMore;
        _currentPage++;
        _isLoading = false;
        _isFirstLoad = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isFirstLoad = false;
        _errorMessage = 'Failed to load users. Please try again.';
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _users.clear();
      _currentPage = 1;
      _hasMore = true;
      _isFirstLoad = true;
      _errorMessage = null;
    });
    await _fetchUsers();
  }

  void _onUserTap(User user) {
    Navigator.pop(context, user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Third Screen'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppTheme.dividerColor),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // First load shimmer
    if (_isFirstLoad) {
      return _buildShimmer();
    }

    // Error state
    if (_errorMessage != null && _users.isEmpty) {
      return _buildErrorState();
    }

    // Empty state
    if (!_isLoading && _users.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppTheme.primaryTeal,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _users.length + (_hasMore ? 1 : 0),
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          color: AppTheme.dividerColor,
          indent: 80,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          if (index >= _users.length) {
            // Bottom loading indicator
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppTheme.primaryTeal,
                  ),
                ),
              ),
            );
          }
          return _UserListItem(
            user: _users[index],
            onTap: () => _onUserTap(_users[index]),
          );
        },
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 8,
        separatorBuilder: (ctx, idx) => const Divider(
          height: 1,
          color: AppTheme.dividerColor,
          indent: 80,
        ),
        itemBuilder: (ctx, idx) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Avatar placeholder
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 11,
                      width: 150,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No users found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull down to refresh',
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 72, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 160,
              child: ElevatedButton(
                onPressed: _onRefresh,
                child: const Text('Try Again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── User List Item ──────────────────────────────────────────────────────────

class _UserListItem extends StatelessWidget {
  final User user;
  final VoidCallback onTap;

  const _UserListItem({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: AppTheme.primaryTeal.withValues(alpha: 0.08),
      highlightColor: AppTheme.primaryTeal.withValues(alpha: 0.04),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Circular avatar
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: user.avatar,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                placeholder: (ctx, url) => Container(
                  width: 56,
                  height: 56,
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.person,
                    size: 28,
                    color: Colors.grey,
                  ),
                ),
                errorWidget: (ctx, url, err) => Container(
                  width: 56,
                  height: 56,
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.person,
                    size: 28,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Name + email
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

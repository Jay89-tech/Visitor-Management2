import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/visit_provider.dart';
import '../../utils/app_theme.dart';
import '../../screens/splash_screen.dart';
import '../visits/visit_list_screen.dart';
import '../visits/create_visit_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import 'widgets/stat_card.dart';
import 'widgets/quick_action_button.dart';
import 'widgets/upcoming_visit_card.dart';
import '../../screens/scanner/qr_scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final visitProvider = Provider.of<VisitProvider>(context, listen: false);
    await visitProvider.loadVisits();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _handleRefresh() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomePage(),
      const VisitListScreen(),
      const NotificationsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _selectedIndex == 0 || _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateVisitScreen(),
                  ),
                );
              },
              backgroundColor: AppTheme.primaryBlue,
              icon: const Icon(Icons.add),
              label: const Text('New Visit'),
            )
          : null,
    );
  }

  Widget _buildHomePage() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),

            // Statistics Cards
            SliverToBoxAdapter(
              child: _buildStatistics(),
            ),

            // Quick Actions
            SliverToBoxAdapter(
              child: _buildQuickActions(),
            ),

            // Upcoming Visits
            SliverToBoxAdapter(
              child: _buildUpcomingVisits(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final visitor = authProvider.visitorProfile;
        final greeting = _getGreeting();

        return Container(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              // Avatar
              Hero(
                tag: 'user_avatar',
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [AppTheme.cardShadow],
                  ),
                  child: Center(
                    child: Text(
                      visitor?.fullName.substring(0, 1).toUpperCase() ?? 'V',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Greeting
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.lightText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      visitor?.fullName ?? 'Visitor',
                      style: AppTheme.heading2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Notification Badge
              IconButton(
                onPressed: () {
                  setState(() => _selectedIndex = 2);
                },
                icon: Stack(
                  children: [
                    const Icon(
                      Icons.notifications_outlined,
                      size: 28,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppTheme.dangerRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatistics() {
    return Consumer<VisitProvider>(
      builder: (context, visitProvider, _) {
        if (_isLoading) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: LoadingWidget(message: 'Loading statistics...'),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Visits',
                style: AppTheme.heading3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.pending_actions,
                      label: 'Pending',
                      value: visitProvider.pendingVisitsCount.toString(),
                      color: AppTheme.warningOrange,
                      onTap: () {
                        setState(() => _selectedIndex = 1);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.check_circle,
                      label: 'Approved',
                      value: visitProvider.approvedVisitsCount.toString(),
                      color: AppTheme.successGreen,
                      onTap: () {
                        setState(() => _selectedIndex = 1);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.event_available,
                      label: 'Today',
                      value: visitProvider.todayVisitsCount.toString(),
                      color: AppTheme.primaryBlue,
                      onTap: () {
                        setState(() => _selectedIndex = 1);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.history,
                      label: 'Total',
                      value: visitProvider.totalVisitsCount.toString(),
                      color: AppTheme.mediumText,
                      onTap: () {
                        setState(() => _selectedIndex = 1);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: AppTheme.heading3,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: QuickActionButton(
                  icon: Icons.add_circle_outline,
                  label: 'New Visit',
                  gradient: AppTheme.primaryGradient,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateVisitScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: QuickActionButton(
                  icon: Icons.qr_code_scanner,
                  label: 'Scan QR',
                  gradient: AppTheme.successGradient,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const QRScannerScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingVisits() {
    return Consumer<VisitProvider>(
      builder: (context, visitProvider, _) {
        final upcomingVisits = visitProvider.upcomingVisits;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Upcoming Visits',
                    style: AppTheme.heading3,
                  ),
                  if (upcomingVisits.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() => _selectedIndex = 1);
                      },
                      child: const Text('View All'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(
                  child: CircularLoadingIndicator(),
                )
              else if (upcomingVisits.isEmpty)
                _buildEmptyState()
              else
                ...upcomingVisits.take(3).map(
                      (visit) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: UpcomingVisitCard(visit: visit),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Upcoming Visits',
            style: AppTheme.heading3.copyWith(
              color: AppTheme.mediumText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Schedule a new visit to get started',
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateVisitScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Visit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() => _selectedIndex = index);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.event_note_outlined),
          selectedIcon: Icon(Icons.event_note),
          label: 'Visits',
        ),
        NavigationDestination(
          icon: Icon(Icons.notifications_outlined),
          selectedIcon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}

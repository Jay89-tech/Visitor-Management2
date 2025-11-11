import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/visit_provider.dart';
import '../../utils/app_theme.dart';
import '../../screens/splash_screen.dart';
import '../../models/visitor_model.dart';
import 'visit_detail_screen.dart';

class VisitListScreen extends StatefulWidget {
  const VisitListScreen({super.key});

  @override
  State<VisitListScreen> createState() => _VisitListScreenState();
}

class _VisitListScreenState extends State<VisitListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Visits'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search visits...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),
              const SizedBox(height: 8),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: AppTheme.primaryBlue,
                unselectedLabelColor: AppTheme.mediumText,
                indicatorColor: AppTheme.primaryBlue,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Pending'),
                  Tab(text: 'Approved'),
                  Tab(text: 'Denied'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Consumer<VisitProvider>(
        builder: (context, visitProvider, _) {
          if (visitProvider.isLoading) {
            return const LoadingWidget(message: 'Loading visits...');
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildVisitList(visitProvider.visits),
              _buildVisitList(visitProvider.pendingVisits),
              _buildVisitList(visitProvider.approvedVisits),
              _buildVisitList(visitProvider.deniedVisits),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVisitList(List<VisitModel> visits) {
    final filteredVisits = visits.where((visit) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return visit.purposeOfVisit.toLowerCase().contains(query) ||
          visit.hostName.toLowerCase().contains(query) ||
          visit.hostDepartment.toLowerCase().contains(query);
    }).toList();

    if (filteredVisits.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<VisitProvider>(context, listen: false).loadVisits();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredVisits.length,
        itemBuilder: (context, index) {
          final visit = filteredVisits[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildVisitCard(visit),
          );
        },
      ),
    );
  }

  Widget _buildVisitCard(VisitModel visit) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VisitDetailScreen(visitId: visit.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.getStatusColor(visit.status).withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [AppTheme.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visit.purposeOfVisit,
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(visit.visitDate),
                        style: AppTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _buildStatusBadge(visit.status),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.person_outline,
              'Host',
              visit.hostName,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.business_outlined,
              'Department',
              visit.hostDepartment,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.access_time_outlined,
              'Time',
              timeFormat.format(visit.expectedArrivalTime),
            ),
            if (visit.isApproved && visit.isToday) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to QR code
                  },
                  icon: const Icon(Icons.qr_code, size: 18),
                  label: const Text('Show QR Code'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
            if (visit.isPending) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showCancelDialog(visit),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text('Cancel Visit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.dangerRed,
                    side: const BorderSide(color: AppTheme.dangerRed),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppTheme.getStatusBackgroundColor(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTheme.bodySmall.copyWith(
          color: AppTheme.getStatusColor(status),
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.mediumText),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.mediumText,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No Visits Found',
            style: AppTheme.heading3.copyWith(
              color: AppTheme.mediumText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search'
                : 'Create your first visit to get started',
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Future<void> _showCancelDialog(VisitModel visit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Visit'),
        content: const Text(
          'Are you sure you want to cancel this visit request?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerRed,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final visitProvider = Provider.of<VisitProvider>(context, listen: false);
      final success = await visitProvider.cancelVisit(visit.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Visit cancelled' : 'Failed to cancel visit',
            ),
            backgroundColor:
                success ? AppTheme.successGreen : AppTheme.dangerRed,
          ),
        );
      }
    }
  }
}

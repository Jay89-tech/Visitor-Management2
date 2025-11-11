import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/visit_provider.dart';
import '../../utils/app_theme.dart';
import '../../screens/splash_screen.dart';
import 'qr_code_screen.dart';

class VisitDetailScreen extends StatelessWidget {
  final String visitId;

  const VisitDetailScreen({
    super.key,
    required this.visitId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<VisitProvider>(
        builder: (context, visitProvider, _) {
          final visit = visitProvider.getVisitById(visitId);

          if (visit == null) {
            return const Center(
              child: Text('Visit not found'),
            );
          }

          final dateFormat = DateFormat('EEEE, MMMM dd, yyyy');
          final timeFormat = DateFormat('hh:mm a');

          return CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                visit.status.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              visit.purposeOfVisit,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Date & Time Card
                      _buildInfoCard(
                        icon: Icons.calendar_today_outlined,
                        title: 'Date & Time',
                        children: [
                          _buildInfoRow(
                            'Date',
                            dateFormat.format(visit.visitDate),
                            Icons.event,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            'Arrival',
                            timeFormat.format(visit.expectedArrivalTime),
                            Icons.login_outlined,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            'Departure',
                            timeFormat.format(visit.expectedDepartureTime),
                            Icons.logout_outlined,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Host Information Card
                      _buildInfoCard(
                        icon: Icons.person_outline,
                        title: 'Host Information',
                        children: [
                          _buildInfoRow(
                            'Name',
                            visit.hostName,
                            Icons.person,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            'Department',
                            visit.hostDepartment,
                            Icons.business,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Visitor Information Card
                      _buildInfoCard(
                        icon: Icons.badge_outlined,
                        title: 'Your Information',
                        children: [
                          _buildInfoRow(
                            'Name',
                            visit.visitorName,
                            Icons.person_outline,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            'Company',
                            visit.visitorCompany,
                            Icons.business_outlined,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            'Email',
                            visit.visitorEmail,
                            Icons.email_outlined,
                          ),
                        ],
                      ),

                      if (visit.notes != null && visit.notes!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          icon: Icons.note_outlined,
                          title: 'Additional Notes',
                          children: [
                            Text(
                              visit.notes!,
                              style: AppTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],

                      if (visit.isDenied && visit.denialReason != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.dangerRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.dangerRed.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.cancel_outlined,
                                    color: AppTheme.dangerRed,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Denial Reason',
                                    style: AppTheme.heading3.copyWith(
                                      color: AppTheme.dangerRed,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                visit.denialReason!,
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.dangerRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Action Buttons
                      if (visit.isApproved && visit.canCheckIn)
                        SizedBox(
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => QRCodeScreen(visit: visit),
                                ),
                              );
                            },
                            icon: const Icon(Icons.qr_code, size: 28),
                            label: const Text(
                              'Show QR Code',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.successGreen,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),

                      if (visit.isPending)
                        SizedBox(
                          height: 56,
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _showCancelDialog(context, visit.id),
                            icon: const Icon(Icons.cancel_outlined),
                            label: const Text('Cancel Visit Request'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.dangerRed,
                              side: const BorderSide(
                                color: AppTheme.dangerRed,
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Visit Status Timeline
                      _buildTimeline(visit),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTheme.heading3.copyWith(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppTheme.mediumText,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.lightText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline(visit) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.history,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Timeline',
                style: AppTheme.heading3.copyWith(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTimelineItem(
            'Request Submitted',
            DateFormat('MMM dd, yyyy - hh:mm a').format(visit.createdAt),
            true,
            AppTheme.primaryBlue,
          ),
          if (visit.approvedAt != null)
            _buildTimelineItem(
              visit.isApproved ? 'Visit Approved' : 'Visit Denied',
              DateFormat('MMM dd, yyyy - hh:mm a').format(visit.approvedAt!),
              true,
              visit.isApproved ? AppTheme.successGreen : AppTheme.dangerRed,
            ),
          if (visit.isPending)
            _buildTimelineItem(
              'Awaiting Approval',
              'Pending review',
              false,
              AppTheme.warningOrange,
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String time,
    bool isCompleted,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isCompleted ? color : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
              ),
              if (title != 'Awaiting Approval')
                Container(
                  width: 2,
                  height: 30,
                  color: color.withOpacity(0.3),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.mediumText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCancelDialog(BuildContext context, String visitId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Cancel Visit'),
        content: const Text(
          'Are you sure you want to cancel this visit request? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Visit'),
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

    if (confirmed == true && context.mounted) {
      final visitProvider = Provider.of<VisitProvider>(context, listen: false);
      final success = await visitProvider.cancelVisit(visitId);

      if (context.mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Visit cancelled successfully'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                visitProvider.errorMessage ?? 'Failed to cancel visit',
              ),
              backgroundColor: AppTheme.dangerRed,
            ),
          );
        }
      }
    }
  }
}

// upcoming_visit_card.dart
import '../../../models/visitor_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';

class UpcomingVisitCard extends StatelessWidget {
  final VisitModel visit;

  const UpcomingVisitCard({
    super.key,
    required this.visit,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return InkWell(
      onTap: () {
        // Navigate to visit details
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
                  child: Text(
                    visit.purposeOfVisit,
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.business_outlined,
              'Host: ${visit.hostName}',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.calendar_today_outlined,
              dateFormat.format(visit.visitDate),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.access_time_outlined,
              timeFormat.format(visit.expectedArrivalTime),
            ),
            if (visit.isApproved && visit.canCheckIn) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to QR code screen
                  },
                  icon: const Icon(Icons.qr_code, size: 20),
                  label: const Text('Show QR Code'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successGreen,
                    foregroundColor: Colors.white,
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

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppTheme.getStatusBackgroundColor(visit.status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        visit.status.toUpperCase(),
        style: AppTheme.bodySmall.copyWith(
          color: AppTheme.getStatusColor(visit.status),
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.mediumText,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.mediumText,
            ),
          ),
        ),
      ],
    );
  }
}

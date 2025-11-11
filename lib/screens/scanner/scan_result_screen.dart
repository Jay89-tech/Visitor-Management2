import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/qr_service.dart';
import '../../utils/app_theme.dart';
import '../../screens/splash_screen.dart';

class ScanResultScreen extends StatefulWidget {
  final QRValidationResult validationResult;

  const ScanResultScreen({
    super.key,
    required this.validationResult,
  });

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final QRService _qrService = QRService();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _processCheckIn() async {
    if (!widget.validationResult.isValid) return;

    setState(() => _isProcessing = true);

    try {
      final result = await _qrService.processCheckIn(
        visitId: widget.validationResult.visitId!,
        verifiedBy: 'Security', // This should be the actual admin/security user
      );

      if (!mounted) return;

      if (result.success) {
        await _showSuccessDialog();
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        _showErrorSnackBar(result.message);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error processing check-in: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.dangerRed,
      ),
    );
  }

  Future<void> _showSuccessDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 50,
                color: AppTheme.successGreen,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Check-In Successful!',
              style: AppTheme.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Visitor has been checked in successfully',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successGreen,
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isValid = widget.validationResult.isValid;
    final color = isValid ? AppTheme.successGreen : AppTheme.dangerRed;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Result Icon
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isValid ? Icons.check_circle : Icons.cancel,
                            size: 70,
                            color: color,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Status Text
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        isValid ? 'Valid QR Code' : 'Invalid QR Code',
                        style: AppTheme.heading1.copyWith(color: color),
                      ),
                    ),

                    const SizedBox(height: 12),

                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        widget.validationResult.message,
                        style: AppTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Visit Details
                    if (isValid && widget.validationResult.visitData != null)
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildVisitDetails(),
                      ),

                    const SizedBox(height: 32),

                    // Action Buttons
                    if (isValid)
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed:
                                    _isProcessing ? null : _processCheckIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.successGreen,
                                ),
                                child: _isProcessing
                                    ? const CircularLoadingIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        'Confirm Check-In',
                                        style: AppTheme.buttonText,
                                      ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                            ),
                            child: const Text(
                              'Scan Again',
                              style: AppTheme.buttonText,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (_isProcessing)
                const LoadingOverlay(message: 'Processing check-in...'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisitDetails() {
    final data = widget.validationResult.visitData!;
    final dateFormat = DateFormat('EEEE, MMMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

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
          const Text(
            'Visit Details',
            style: AppTheme.heading3,
          ),
          const SizedBox(height: 20),
          _buildDetailRow(
            Icons.person_outline,
            'Visitor',
            data['visitorName'] ?? 'Unknown',
          ),
          const Divider(height: 24),
          _buildDetailRow(
            Icons.business_outlined,
            'Company',
            data['visitorCompany'] ?? 'Unknown',
          ),
          const Divider(height: 24),
          _buildDetailRow(
            Icons.assignment_outlined,
            'Purpose',
            data['purposeOfVisit'] ?? 'Unknown',
          ),
          const Divider(height: 24),
          _buildDetailRow(
            Icons.person,
            'Host',
            data['hostName'] ?? 'Unknown',
          ),
          const Divider(height: 24),
          _buildDetailRow(
            Icons.event,
            'Date',
            dateFormat.format(data['visitDate'].toDate()),
          ),
          const Divider(height: 24),
          _buildDetailRow(
            Icons.access_time,
            'Expected Time',
            timeFormat.format(data['expectedArrivalTime'].toDate()),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.mediumText),
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
}

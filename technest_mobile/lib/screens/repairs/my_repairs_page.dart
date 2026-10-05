import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/repair_model.dart';
import '../../services/repair_service.dart';

class MyRepairsPage extends StatefulWidget {
  const MyRepairsPage({super.key});

  @override
  State<MyRepairsPage> createState() => _MyRepairsPageState();
}

class _MyRepairsPageState extends State<MyRepairsPage> {
  final RepairService _repairService = RepairService();

  List<RepairModel> _repairs = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Pending',
    'In Progress',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _loadRepairs();
  }

  Future<void> _loadRepairs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repairs = await _repairService.getMyRepairs();

      if (!mounted) return;

      setState(() {
        _repairs = repairs;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  List<RepairModel> get _filteredRepairs {
    if (_selectedFilter == 'All') {
      return _repairs;
    }

    return _repairs.where((repair) {
      return _normalizeStatus(repair.status) ==
          _normalizeStatus(_selectedFilter);
    }).toList();
  }

  String _normalizeStatus(String status) {
    return status.trim().toLowerCase().replaceAll('_', ' ');
  }

  Color _statusColor(String status) {
    switch (_normalizeStatus(status)) {
      case 'completed':
        return AppColors.success;

      case 'cancelled':
      case 'canceled':
        return AppColors.error;

      case 'in progress':
      case 'inprogress':
        return AppColors.info;

      case 'pending':
        return AppColors.warning;

      default:
        return AppColors.textSecondary;
    }
  }

  IconData _statusIcon(String status) {
    switch (_normalizeStatus(status)) {
      case 'completed':
        return Icons.check_circle_rounded;

      case 'cancelled':
      case 'canceled':
        return Icons.cancel_rounded;

      case 'in progress':
      case 'inprogress':
        return Icons.build_circle_rounded;

      case 'pending':
        return Icons.schedule_rounded;

      default:
        return Icons.info_rounded;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour == 0
        ? 12
        : date.hour > 12
        ? date.hour - 12
        : date.hour;

    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  String _formatCost(double cost) {
    if (cost <= 0) {
      return 'Pending';
    }

    return formatPrice(cost, prefix: 'Rs. ');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.dark : AppColors.background,
      appBar: AppBar(
        title: const Text(
          'My Repairs',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.dark : AppColors.background,
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadRepairs,
        child: _buildBody(isDark),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState(isDark);
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
      children: [
        _buildFilterSection(isDark),
        const SizedBox(height: 18),
        if (_filteredRepairs.isEmpty)
          _buildEmptyState(isDark)
        else
          ..._filteredRepairs.map(
            (repair) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _buildRepairCard(repair, isDark),
            ),
          ),
      ],
    );
  }

  Widget _buildFilterSection(bool isDark) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final selected = filter == _selectedFilter;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : isDark
                    ? AppColors.darkCard
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : isDark
                      ? Colors.white12
                      : AppColors.border,
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? Colors.white
                      : isDark
                      ? Colors.white70
                      : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRepairCard(RepairModel repair, bool isDark) {
    final statusColor = _statusColor(repair.status);

    return InkWell(
      onTap: () => _showRepairDetails(repair, isDark),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isDark ? Colors.white12 : AppColors.border),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.build_rounded,
                    color: AppColors.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        repair.deviceModel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Repair #${repair.id}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white54
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                ),
              ],
            ),
            const SizedBox(height: 15),
            Divider(
              height: 1,
              color: isDark ? Colors.white10 : AppColors.borderLight,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  size: 17,
                  color: isDark ? Colors.white54 : AppColors.textSecondary,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    _formatDate(repair.appointmentDate),
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                ),
                Icon(
                  Icons.access_time_rounded,
                  size: 17,
                  color: isDark ? Colors.white54 : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatTime(repair.appointmentDate),
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(_statusIcon(repair.status), size: 18, color: statusColor),
                const SizedBox(width: 7),
                Text(
                  repair.status,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatCost(repair.estimatedCost),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.build_outlined,
              size: 42,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _selectedFilter == 'All'
                ? 'No repair requests yet'
                : 'No $_selectedFilter repairs',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'All'
                ? 'Your repair requests will appear here.'
                : 'There are no repairs with this status.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 100),
      children: [
        const Icon(
          Icons.error_outline_rounded,
          size: 60,
          color: AppColors.error,
        ),
        const SizedBox(height: 18),
        Text(
          'Unable to load repairs',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _errorMessage ?? 'Something went wrong.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white54 : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: _loadRepairs,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Try Again'),
          ),
        ),
      ],
    );
  }

  void _showRepairDetails(RepairModel repair, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.dark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.build_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            repair.deviceModel,
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Repair #${repair.id}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white54
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _buildStatusBanner(repair, isDark),
                const SizedBox(height: 20),
                if (repair.imageUrl != null && repair.imageUrl!.isNotEmpty)
                  _buildRepairImage(repair.imageUrl!),
                if (repair.imageUrl != null && repair.imageUrl!.isNotEmpty)
                  const SizedBox(height: 20),
                _buildInfoRow(
                  Icons.devices_rounded,
                  'Device',
                  repair.deviceModel,
                  isDark,
                ),
                const SizedBox(height: 18),
                _buildInfoRow(
                  Icons.description_outlined,
                  'Issue',
                  repair.issueDescription,
                  isDark,
                ),
                const SizedBox(height: 18),
                _buildInfoRow(
                  Icons.calendar_month_rounded,
                  'Appointment',
                  '${_formatDate(repair.appointmentDate)} '
                      'at ${_formatTime(repair.appointmentDate)}',
                  isDark,
                ),
                const SizedBox(height: 18),
                _buildInfoRow(
                  Icons.payments_outlined,
                  'Estimated Cost',
                  _formatCost(repair.estimatedCost),
                  isDark,
                ),
                if (repair.technicianId != null) ...[
                  const SizedBox(height: 18),
                  _buildInfoRow(
                    Icons.engineering_outlined,
                    'Technician',
                    'Technician #${repair.technicianId}',
                    isDark,
                  ),
                ],
                if (repair.repairServiceId != null) ...[
                  const SizedBox(height: 18),
                  _buildInfoRow(
                    Icons.miscellaneous_services_outlined,
                    'Repair Service',
                    'Service #${repair.repairServiceId}',
                    isDark,
                  ),
                ],
                if (repair.aiDiagnosticReport != null &&
                    repair.aiDiagnosticReport!.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  _buildDiagnosticSection(repair.aiDiagnosticReport!, isDark),
                ],
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.darkTertiary
                          : Colors.grey.shade100,
                      foregroundColor: isDark
                          ? Colors.white
                          : AppColors.textPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBanner(RepairModel repair, bool isDark) {
    final statusColor = _statusColor(repair.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Icon(_statusIcon(repair.status), color: statusColor, size: 21),
          const SizedBox(width: 10),
          Text(
            repair.status,
            style: TextStyle(
              color: statusColor,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepairImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        imageUrl,
        width: double.infinity,
        height: 190,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return Container(
            height: 190,
            color: Colors.grey.shade100,
            alignment: Alignment.center,
            child: const Icon(
              Icons.broken_image_outlined,
              size: 40,
              color: Colors.grey,
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return SizedBox(
            height: 190,
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: isDark ? Colors.white70 : Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiagnosticSection(String report, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'AI Diagnostic Report',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            report,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

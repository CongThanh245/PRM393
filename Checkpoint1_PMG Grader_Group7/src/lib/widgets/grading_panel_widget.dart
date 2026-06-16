import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/submission.dart';
import '../models/exam_type.dart';

class GradingPanelWidget extends StatefulWidget {
  final Submission submission;
  final VoidCallback onAskAi;
  final VoidCallback onCopyAiToTeacher;
  final VoidCallback onSaveScores;
  final List<TextEditingController> scoreControllers;
  final TextEditingController commentController;
  final bool hasNext;
  final ValueChanged<String> onRubricChanged;
  final String? selectedMarker;

  const GradingPanelWidget({
    super.key,
    required this.submission,
    required this.onAskAi,
    required this.onCopyAiToTeacher,
    required this.onSaveScores,
    required this.scoreControllers,
    required this.commentController,
    required this.hasNext,
    required this.onRubricChanged,
    this.selectedMarker,
  });

  @override
  State<GradingPanelWidget> createState() => _GradingPanelWidgetState();
}

class _GradingPanelWidgetState extends State<GradingPanelWidget> {
  int _activeTabIndex = 0; // 0 for Tổng quan, 1 for GV chấm, 2 for AI tool
  late TextEditingController _rubricController;

  @override
  void initState() {
    super.initState();
    final exam = widget.submission.examType ?? defaultExamTypes.first;
    _rubricController = TextEditingController(text: exam.customRubric ?? "");
    _rubricController.addListener(_onRubricTextChanged);
  }

  void _onRubricTextChanged() {
    widget.onRubricChanged(_rubricController.text);
  }

  @override
  void didUpdateWidget(covariant GradingPanelWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.submission != oldWidget.submission || 
        widget.submission.examType != oldWidget.submission.examType) {
      final exam = widget.submission.examType ?? defaultExamTypes.first;
      // Temporarily remove listener to avoid triggering callback during text reset
      _rubricController.removeListener(_onRubricTextChanged);
      _rubricController.text = exam.customRubric ?? "";
      _rubricController.addListener(_onRubricTextChanged);
    }
  }

  @override
  void dispose() {
    _rubricController.removeListener(_onRubricTextChanged);
    _rubricController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exam = widget.submission.examType ?? defaultExamTypes.first;
    widget.submission.initScores(exam);
    final hasRubric = exam.customRubric != null && exam.customRubric!.isNotEmpty;

    return Container(
      width: 480,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(
            color: Color(0xFFF1F5F9),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // 3 Tabs Header
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(
                bottom: BorderSide(color: Color(0xFFF1F5F9)),
              ),
            ),
            child: Row(
              children: [
                // Tab 1: Tổng quan
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _activeTabIndex = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _activeTabIndex == 0 ? const Color(0xFF6366F1) : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.summarize_outlined,
                            size: 16,
                            color: _activeTabIndex == 0 ? const Color(0xFF6366F1) : const Color(0xFF64748B),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'TỔNG QUAN',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 0.5,
                              color: _activeTabIndex == 0 ? const Color(0xFF6366F1) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(width: 1, height: 24, color: const Color(0xFFE2E8F0)),
                // Tab 2: GV chấm
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _activeTabIndex = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _activeTabIndex == 1 ? const Color(0xFF6366F1) : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.rate_review_outlined,
                            size: 16,
                            color: _activeTabIndex == 1 ? const Color(0xFF6366F1) : const Color(0xFF64748B),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'GV CHẤM',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 0.5,
                              color: _activeTabIndex == 1 ? const Color(0xFF6366F1) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(width: 1, height: 24, color: const Color(0xFFE2E8F0)),
                // Tab 3: AI tool
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _activeTabIndex = 2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _activeTabIndex == 2 ? const Color(0xFF6366F1) : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.smart_toy_outlined,
                            size: 16,
                            color: _activeTabIndex == 2 ? const Color(0xFF6366F1) : const Color(0xFF64748B),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'AI TOOL',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 0.5,
                              color: _activeTabIndex == 2 ? const Color(0xFF6366F1) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Tab Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: _buildActiveTabContent(exam, hasRubric),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTabContent(ExamType exam, bool hasRubric) {
    switch (_activeTabIndex) {
      case 0:
        return _buildOverviewTab(exam);
      case 1:
        return _buildAssessmentTab(exam);
      case 2:
        return _buildAiToolTab(hasRubric);
      default:
        return const SizedBox();
    }
  }

  Widget _buildOverviewTab(ExamType exam) {
    return Column(
      key: const ValueKey('overview_tab'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question summary
        Text(
          'CẤU TRÚC ĐIỂM ĐỀ THI',
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF94A3B8),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        ..._buildOverviewRequirementCards(exam),
        const SizedBox(height: 16),
        _buildTotalOverviewCard(exam),
      ],
    );
  }

  Widget _buildAiToolTab(bool hasRubric) {
    final sub = widget.submission;
    final exam = sub.examType ?? defaultExamTypes.first;

    return Column(
      key: const ValueKey('ai_tab'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: hasRubric ? widget.onAskAi : null,
          icon: const Icon(Icons.smart_toy, size: 16),
          label: const Text('Chấm bằng AI'),
          style: ElevatedButton.styleFrom(
            backgroundColor: hasRubric ? const Color(0xFFEEF2FF) : const Color(0xFFF1F5F9),
            foregroundColor: hasRubric ? const Color(0xFF6366F1) : const Color(0xFF94A3B8),
            disabledBackgroundColor: const Color(0xFFF1F5F9),
            disabledForegroundColor: const Color(0xFF94A3B8),
            elevation: 0,
            minimumSize: const Size(double.infinity, 42),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        if (!hasRubric) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E6), // light amber
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFE0B2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFD97706),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Vui lòng nhập hoặc nạp tiêu chí chấm điểm ở tab Tổng Quan để bắt đầu chấm bằng AI',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFB45309),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        if (sub.hasAiGraded) ...[
          Text(
            'ĐIỂM AI GỢI Ý',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF94A3B8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          // Render AI scores grouped by requirement
          ..._buildAiScoreGroupRows(exam, sub),
          const Divider(height: 32),
          Text(
            'Nhận xét AI:',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sub.aiComment,
            style: GoogleFonts.inter(
              fontSize: 12,
              height: 1.5,
              color: const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              widget.onCopyAiToTeacher();
              setState(() => _activeTabIndex = 1);
            },
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Áp dụng điểm AI'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD1FAE5),
              foregroundColor: const Color(0xFF065F46),
              elevation: 0,
              minimumSize: const Size(double.infinity, 42),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          )
        ] else
          const Padding(
            padding: EdgeInsets.only(top: 48.0),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.smart_toy_outlined, size: 48, color: Color(0xFFCBD5E1)),
                  SizedBox(height: 12),
                  Text(
                    'Chưa có kết quả AI.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          )
      ],
    );
  }

  Widget _buildAssessmentTab(ExamType exam) {
    return Column(
      key: const ValueKey('assessment_tab'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Marker information
        if (widget.selectedMarker != null && widget.selectedMarker!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFC7D2FE)),
            ),
            child: Row(
              children: [
                Icon(Icons.person_rounded, size: 16, color: const Color(0xFF6366F1)),
                const SizedBox(width: 8),
                Text(
                  'Người chấm: ${widget.selectedMarker}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4F46E5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        ..._buildCriterionInputRows(exam),
        const Divider(height: 24),
        _buildCommentField(widget.commentController),
        const SizedBox(height: 20),
        // Total summary card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'TỔNG ĐIỂM (Thang 10)',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: const Color(0xFF475569),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Builder(
                builder: (context) {
                  double t = 0;
                  for (var controller in widget.scoreControllers) {
                    t += double.tryParse(controller.text) ?? 0.0;
                  }
                  return Text(
                    '${t.toStringAsFixed(1)} / 10.0',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4F46E5),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.onSaveScores,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              widget.hasNext ? 'Lưu & Bài tiếp theo' : 'Hoàn tất chấm điểm',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAiScoreExpansionTile(String label, double score, double maxScore, String comment) {
    // Parse bullet lines: lines starting with "•" are sub-criteria rows, rest is plain text
    final lines = comment.isNotEmpty
        ? comment.split('\n').where((l) => l.trim().isNotEmpty).toList()
        : <String>[];
    final bulletLines = lines.where((l) => l.trimLeft().startsWith('•')).toList();
    final otherLines = lines.where((l) => !l.trimLeft().startsWith('•')).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${score.toStringAsFixed(1)} / $maxScore',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4F46E5),
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
          children: [
            if (comment.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Không có nhận xét từ AI cho câu này.',
                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                ),
              )
            else ...[
              // Sub-criteria bullet rows
              if (bulletLines.isNotEmpty)
                ...bulletLines.map((line) {
                  final content = line.replaceFirst(RegExp(r'^[\s•]+'), '').trim();
                  final colonIdx = content.indexOf(':');
                  final subName = colonIdx >= 0 ? content.substring(0, colonIdx).trim() : content;
                  final subDetail = colonIdx >= 0 ? content.substring(colonIdx + 1).trim() : '';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 3),
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF6366F1),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: subName.isNotEmpty ? '$subName: ' : '',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF334155),
                                  ),
                                ),
                                TextSpan(
                                  text: subDetail,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: const Color(0xFF475569),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              // Non-bullet lines (any leading plain text)
              if (otherLines.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: bulletLines.isNotEmpty ? 6 : 0),
                  child: Text(
                    otherLines.join(' '),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      height: 1.5,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCriterionInputRows(ExamType exam) {
    final widgets = <Widget>[];
    final grouped = _groupCriteriaByRequirement(exam);

    for (int i = 0; i < grouped.length; i++) {
      final group = grouped[i];
      final currentScore = group.indexes.fold<double>(0, (sum, index) {
        if (index >= widget.scoreControllers.length) return sum;
        return sum + (double.tryParse(widget.scoreControllers[index].text) ?? 0.0);
      });
      widgets.add(Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: false,
            tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${i + 1}',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6366F1),
                  ),
                ),
              ),
            ),
            title: Text(
              group.title,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            subtitle: Text(
              '${group.criteria.length} tiêu chí con',
              style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${currentScore.toStringAsFixed(1)} / ${group.maxScore10.toStringAsFixed(1)}',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.expand_more, color: Color(0xFF64748B), size: 20),
              ],
            ),
            children: [
              ...group.indexes.map((index) {
                if (index >= widget.scoreControllers.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8, bottom: 10),
                  child: _buildCriterionScoreCard(
                    exam.criteria[index],
                    widget.scoreControllers[index],
                  ),
                );
              }),
            ],
          ),
        ),
      ));
    }

    return widgets;
  }

  List<Widget> _buildOverviewRequirementCards(ExamType exam) {
    final grouped = _groupCriteriaByRequirement(exam);
    return grouped.map((group) {
      final currentScore = group.indexes.fold<double>(0, (sum, index) {
        if (index >= widget.submission.scores.length) return sum;
        return sum + widget.submission.scores[index];
      });
      final isGraded = widget.submission.graded;
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isGraded ? const Color(0xFFD1FAE5) : const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isGraded ? Icons.check_rounded : Icons.article_outlined,
                size: 18,
                color: isGraded ? const Color(0xFF10B981) : const Color(0xFF6366F1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${group.criteria.length} tiêu chí con',
                    style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              isGraded
                  ? '${currentScore.toStringAsFixed(1)} / ${group.maxScore10.toStringAsFixed(1)}'
                  : '0.0 / ${group.maxScore10.toStringAsFixed(1)}',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isGraded ? const Color(0xFF10B981) : const Color(0xFF6366F1),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildTotalOverviewCard(ExamType exam) {
    final total = widget.submission.graded ? widget.submission.total : 0.0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC7D2FE)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Tổng điểm',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          Text(
            '${total.toStringAsFixed(1)} / ${exam.totalMaxScore10.toStringAsFixed(1)}',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4F46E5),
            ),
          ),
        ],
      ),
    );
  }

  List<_RequirementGroup> _groupCriteriaByRequirement(ExamType exam) {
    final groups = <_RequirementGroup>[];
    final groupMap = <String, _RequirementGroup>{};

    for (int i = 0; i < exam.criteria.length; i++) {
      final criterion = exam.criteria[i];
      final key = criterion.requirementId ??
          criterion.requirementTitle ??
          'REQ_${i + 1}';
      final title = criterion.requirementTitle ??
          criterion.requirementId ??
          criterion.name;
      final group = groupMap.putIfAbsent(key, () {
        final created = _RequirementGroup(title);
        groups.add(created);
        return created;
      });
      group.criteria.add(criterion);
      group.indexes.add(i);
    }

    return groups;
  }

  List<Widget> _buildAiScoreGroupRows(ExamType exam, Submission sub) {
    final grouped = _groupCriteriaByRequirement(exam);
    final widgets = <Widget>[];

    for (int i = 0; i < grouped.length; i++) {
      final group = grouped[i];
      final currentScore = group.indexes.fold<double>(0, (sum, index) {
        if (index >= sub.aiScores.length) return sum;
        return sum + sub.aiScores[index];
      });
      widgets.add(Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: false,
            tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${i + 1}',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6366F1),
                  ),
                ),
              ),
            ),
            title: Text(
              group.title,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            subtitle: Text(
              '${group.criteria.length} tiêu chí con',
              style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${currentScore.toStringAsFixed(1)} / ${group.maxScore10.toStringAsFixed(1)}',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.expand_more, color: Color(0xFF64748B), size: 20),
              ],
            ),
            children: [
              ...group.indexes.map((index) {
                if (index >= sub.aiScores.length || index >= sub.aiComments.length) {
                  return const SizedBox.shrink();
                }
                final c = exam.criteria[index];
                final scoreVal = sub.aiScores[index];
                final commentVal = sub.aiComments[index];
                return Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8, bottom: 10),
                  child: _buildAiScoreExpansionTile(
                    '${c.id != null ? '${c.id}. ' : ''}${c.name}',
                    scoreVal,
                    c.maxScore10,
                    commentVal,
                  ),
                );
              }),
            ],
          ),
        ),
      ));
    }

    return widgets;
  }

  Widget _buildCriterionScoreCard(Criterion criterion, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '${criterion.id != null ? '${criterion.id}. ' : ''}${criterion.name}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Max ${criterion.maxScore10.toStringAsFixed(1)}',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6366F1),
                ),
              ),
            ],
          ),
          if ((criterion.fullDescription ?? '').isNotEmpty ||
              (criterion.partialDescription ?? '').isNotEmpty ||
              (criterion.failDescription ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildLevelText('Đạt', criterion.fullDescription, const Color(0xFF047857)),
            _buildLevelText('Một phần', criterion.partialDescription, const Color(0xFFD97706)),
            _buildLevelText('Chưa đạt', criterion.failDescription, const Color(0xFFDC2626)),
          ],
          if (criterion.commonErrors != null && criterion.commonErrors!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E6),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFFFE0B2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 14, color: const Color(0xFFD97706)),
                      const SizedBox(width: 4),
                      Text(
                        'Lỗi thường gặp:',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ...criterion.commonErrors!.map((error) => Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Text(
                      '• $error',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: const Color(0xFFB45309),
                        height: 1.3,
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
            onChanged: (value) {
              setState(() {});
            },
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              hintText: 'Nhập điểm',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: _getScoreFieldBorderColor(controller.text, criterion.maxScore10),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: _getScoreFieldBorderColor(controller.text, criterion.maxScore10),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: _getScoreFieldBorderColor(controller.text, criterion.maxScore10),
                  width: 1.5,
                ),
              ),
              errorText: _getScoreFieldError(controller.text, criterion.maxScore10),
              errorStyle: GoogleFonts.inter(fontSize: 10, color: const Color(0xFFDC2626)),
            ),
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF1E293B)),
          ),
        ],
      ),
    );
  }

  Color _getScoreFieldBorderColor(String value, double maxScore) {
    if (value.isEmpty) return const Color(0xFFE2E8F0);
    final score = double.tryParse(value);
    if (score == null) return const Color(0xFFDC2626);
    if (score < 0 || score > maxScore) return const Color(0xFFDC2626);
    return const Color(0xFF10B981);
  }

  String? _getScoreFieldError(String value, double maxScore) {
    if (value.isEmpty) return null;
    final score = double.tryParse(value);
    if (score == null) return 'Điểm phải là số';
    if (score < 0 || score > maxScore) return 'Điểm phải từ 0 đến $maxScore';
    return null;
  }

  Widget _buildLevelText(String label, String? text, Color color) {
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: color),
            ),
            TextSpan(
              text: text,
              style: GoogleFonts.inter(fontSize: 11, height: 1.35, color: const Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentField(TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nhận xét người chấm',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            hintText: 'Nhập ý kiến đánh giá...',
            hintStyle: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF6366F1)),
            ),
          ),
          style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF1E293B)),
        ),
      ],
    );
  }
}

class CopyCommentButton extends StatefulWidget {
  final String textToCopy;
  final String successMessage;

  const CopyCommentButton({
    super.key,
    required this.textToCopy,
    required this.successMessage,
  });

  @override
  State<CopyCommentButton> createState() => _CopyCommentButtonState();
}

class _RequirementGroup {
  final String title;
  final List<Criterion> criteria = [];
  final List<int> indexes = [];

  _RequirementGroup(this.title);

  double get maxScore10 => criteria.fold(0.0, (sum, criterion) => sum + criterion.maxScore10);
}

class _CopyCommentButtonState extends State<CopyCommentButton> {
  bool _copied = false;

  void _handleCopy() {
    if (widget.textToCopy.isEmpty) return;
    Clipboard.setData(ClipboardData(text: widget.textToCopy));
    
    setState(() {
      _copied = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.successMessage,
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: const Color(0xFF10B981), // emerald success color
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _copied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _copied ? 'Đã sao chép!' : 'Sao chép nhận xét',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: widget.textToCopy.isNotEmpty ? _handleCopy : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _copied ? const Color(0xFFD1FAE5) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _copied ? const Color(0xFF34D399) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Icon(
              _copied ? Icons.check_rounded : Icons.copy_rounded,
              size: 16,
              color: _copied ? const Color(0xFF059669) : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }
}

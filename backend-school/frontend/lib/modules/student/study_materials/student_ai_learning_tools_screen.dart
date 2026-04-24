import 'package:flutter/material.dart';
import '../../../common/fonts/common_textstyle.dart';
import '../../../common/theme/app_color.dart';
import '../../../common/utils/responsive.dart';
import '../../../widgets/app_scaffold.dart';
import 'models/study_material_models.dart';

class StudentAiLearningToolsScreen extends StatefulWidget {
  const StudentAiLearningToolsScreen({super.key, required this.items});
  final List<StudyMaterialItem> items;

  @override
  State<StudentAiLearningToolsScreen> createState() => _StudentAiLearningToolsScreenState();
}

class _StudentAiLearningToolsScreenState extends State<StudentAiLearningToolsScreen> {
  StudyMaterialItem? _selected;
  final _mathProblemController = TextEditingController();
  final _doubtController = TextEditingController();
  final _chapterTopicController = TextEditingController();
  String _output = '';
  String _mode = '';
  int _quizQuestionCount = 8;
  String _difficulty = 'Medium';

  @override
  void initState() {
    super.initState();
    if (widget.items.isNotEmpty) _selected = widget.items.first;
    if (_selected != null) {
      _chapterTopicController.text = _selected!.title;
    }
  }

  @override
  void dispose() {
    _mathProblemController.dispose();
    _doubtController.dispose();
    _chapterTopicController.dispose();
    super.dispose();
  }

  void _generate(String mode) {
    final item = _selected;
    final chapter = _chapterTopicController.text.trim().isEmpty
        ? (item?.title ?? 'General topic')
        : _chapterTopicController.text.trim();
    final details = item == null
        ? 'No material selected'
        : (item.description.isEmpty ? item.subject : item.description);
    String text;
    switch (mode) {
      case 'math':
        final problem = _mathProblemController.text.trim();
        if (problem.isEmpty) {
          _showInfo('Please type a math problem first.');
          return;
        }
        text =
            'Math Problem Explanation\n\nProblem:\n$problem\n\nStep-by-step explanation:\n1) Identify given values and unknown.\n2) Select formula/rule needed.\n3) Substitute values correctly.\n4) Solve carefully and verify unit/sign.\n\nQuick tip:\nCheck final answer by back-substitution.';
        break;
      case 'summary':
        text =
            'Chapter Summary\n\nTopic: $chapter\n\nContext:\n$details\n\n- Core concept overview\n- Important definitions/formulas\n- 3 key exam points\n- 1 common mistake to avoid\n- 1 quick revision strategy';
        break;
      case 'doubt':
        final doubt = _doubtController.text.trim();
        if (doubt.isEmpty) {
          _showInfo('Please type your doubt first.');
          return;
        }
        text =
            'Doubt Resolution\n\nYour doubt:\n$doubt\n\nResolution path:\n1) Clarified the concept in simple words.\n2) Connected with chapter "$chapter".\n3) Provided an example use case.\n4) Added what to revise next.\n\nPractice follow-up:\nSolve 2 similar short questions now.';
        break;
      case 'quiz':
        text = _buildQuizAndPaper(chapter);
        break;
      default:
        text = 'Unsupported action';
        break;
    }
    setState(() {
      _mode = mode;
      _output = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'AI Student Assistant',
      body: ListView(
        padding: EdgeInsets.all(Responsive.w(context, 16)),
        children: [
          Text(
            'Smart AI workflows for students',
            style: AppTextStyle.titleLarge(context).copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: Responsive.h(context, 6)),
          Text(
            'Ask AI to explain math problems, summarize chapter topics, solve doubts, and create quiz/paper.',
            style: AppTextStyle.bodySmall(context).copyWith(color: AppColor.textSecondary),
          ),
          SizedBox(height: Responsive.h(context, 14)),
          DropdownButtonFormField<StudyMaterialItem>(
            value: _selected,
            items: widget.items
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e.title, overflow: TextOverflow.ellipsis),
                    ))
                .toList(),
            onChanged: (v) {
              setState(() {
                _selected = v;
                if (v != null && _chapterTopicController.text.trim().isEmpty) {
                  _chapterTopicController.text = v.title;
                }
              });
            },
            decoration: InputDecoration(
              labelText: 'Select chapter/resource (optional)',
              border: const OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: Responsive.w(context, 12),
                vertical: Responsive.h(context, 12),
              ),
            ),
          ),
          SizedBox(height: Responsive.h(context, 12)),
          _toolCard(
            context: context,
            title: '1) Explain math problem',
            subtitle: 'Paste or type a math question and get a guided solution approach.',
            child: Column(
              children: [
                TextFormField(
                  controller: _mathProblemController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Example: Solve 2x + 5 = 17',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: Responsive.h(context, 10)),
                _action('Explain Math Problem', () => _generate('math')),
              ],
            ),
          ),
          SizedBox(height: Responsive.h(context, 12)),
          _toolCard(
            context: context,
            title: '2) Summarize chapter',
            subtitle: 'Generate short and exam-focused chapter summary.',
            child: Column(
              children: [
                TextFormField(
                  controller: _chapterTopicController,
                  decoration: const InputDecoration(
                    hintText: 'Example: Algebraic Expressions',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: Responsive.h(context, 10)),
                _action('Summarize Chapter', () => _generate('summary')),
              ],
            ),
          ),
          SizedBox(height: Responsive.h(context, 12)),
          _toolCard(
            context: context,
            title: '3) Solve doubts',
            subtitle: 'Ask concept confusion in simple language.',
            child: Column(
              children: [
                TextFormField(
                  controller: _doubtController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Example: Difference between speed and velocity?',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: Responsive.h(context, 10)),
                _action('Solve Doubt', () => _generate('doubt')),
              ],
            ),
          ),
          SizedBox(height: Responsive.h(context, 12)),
          _toolCard(
            context: context,
            title: '4) Create quiz and paper',
            subtitle: 'Generate practice quiz/paper by topic, level and question count.',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _difficulty,
                        items: const [
                          DropdownMenuItem(value: 'Easy', child: Text('Easy')),
                          DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                          DropdownMenuItem(value: 'Hard', child: Text('Hard')),
                        ],
                        onChanged: (v) => setState(() => _difficulty = v ?? 'Medium'),
                        decoration: const InputDecoration(
                          labelText: 'Difficulty',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: Responsive.w(context, 10)),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _quizQuestionCount,
                        items: const [5, 8, 10, 15]
                            .map((n) => DropdownMenuItem(value: n, child: Text('$n questions')))
                            .toList(),
                        onChanged: (v) => setState(() => _quizQuestionCount = v ?? 8),
                        decoration: const InputDecoration(
                          labelText: 'Question count',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(context, 10)),
                _action('Create Quiz/Paper', () => _generate('quiz')),
              ],
            ),
          ),
          SizedBox(height: Responsive.h(context, 16)),
          if (_output.isNotEmpty)
            Container(
              padding: EdgeInsets.all(Responsive.w(context, 14)),
              decoration: BoxDecoration(
                color: AppColor.base,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColor.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _mode.toUpperCase(),
                    style: AppTextStyle.titleSmall(context).copyWith(
                      color: AppColor.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: Responsive.h(context, 8)),
                  Text(_output, style: AppTextStyle.bodySmall(context).copyWith(height: 1.45)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _toolCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(context, 14)),
      decoration: BoxDecoration(
        color: AppColor.base,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyle.titleMedium(context).copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: Responsive.h(context, 4)),
          Text(
            subtitle,
            style: AppTextStyle.bodySmall(context).copyWith(color: AppColor.textSecondary),
          ),
          SizedBox(height: Responsive.h(context, 10)),
          child,
        ],
      ),
    );
  }

  Widget _action(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(onPressed: onTap, child: Text(label)),
    );
  }

  String _buildQuizAndPaper(String chapter) {
    final lines = <String>[
      'Quiz / Practice Paper',
      '',
      'Topic: $chapter',
      'Difficulty: $_difficulty',
      'Questions: $_quizQuestionCount',
      '',
      'Section A - Objective',
    ];
    for (int i = 1; i <= (_quizQuestionCount / 2).round(); i++) {
      lines.add('Q$i. MCQ based on $chapter concept $i');
    }
    lines.add('');
    lines.add('Section B - Short/Long');
    for (int i = (_quizQuestionCount / 2).round() + 1; i <= _quizQuestionCount; i++) {
      lines.add('Q$i. Descriptive/application question on $chapter');
    }
    lines.add('');
    lines.add('Teacher note: Auto-generated frontend demo paper.');
    return lines.join('\n');
  }

  void _showInfo(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

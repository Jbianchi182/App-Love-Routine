import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:love_routine_app/features/education/domain/models/subject.dart';
import 'package:love_routine_app/features/education/domain/models/course.dart';
import 'package:love_routine_app/features/education/domain/models/grade_entry.dart';
import 'package:love_routine_app/features/education/presentation/providers/education_provider.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:love_routine_app/features/education/presentation/providers/grading_scheme_provider.dart';

class SubjectDetailsPage extends ConsumerStatefulWidget {
  final Subject subject;
  final Course course;

  const SubjectDetailsPage({super.key, required this.subject, required this.course});

  @override
  ConsumerState<SubjectDetailsPage> createState() => _SubjectDetailsPageState();
}

class _SubjectDetailsPageState extends ConsumerState<SubjectDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch provider to get updates (e.g. new grades)
    // Watch provider to get updates
    final courses = ref.watch(educationProvider).asData?.value ?? [];
    
    // Find our course
    final currentCourse = courses.firstWhere(
      (c) => c.key == widget.course.key,
      orElse: () => widget.course,
    );

    // Find our subject
    final currentSubject = currentCourse.subjects.firstWhere(
      (s) => s.key == widget.subject.key,
      orElse: () => widget.subject,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(currentSubject.name),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          indicatorColor: Colors.white,
          indicatorWeight: 4,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          tabs: const [
            Tab(text: 'Notas', icon: Icon(Icons.grade)),
            Tab(text: 'Calculadora', icon: Icon(Icons.calculate)),
            Tab(text: 'Anotações', icon: Icon(Icons.edit_note)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _GradesTab(subject: currentSubject, course: currentCourse),
          _CalculatorTab(subject: currentSubject, course: currentCourse),
          _NotesTab(subject: currentSubject),
        ],
      ),
    );
  }
}

class _GradesTab extends ConsumerWidget {
  final Subject subject;
  final Course course;

  const _GradesTab({required this.subject, required this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grades = subject.grades;
    final average = _calculateAverage(grades, ref);
    final passing = subject.passingScore ?? 6.0;
    final isPassing = average >= passing;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Average Card
        Card(
          color: isPassing ? Colors.green.shade50 : Colors.red.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Média Atual',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  average.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: isPassing ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isPassing ? 'Aprovado' : 'Reprovado',
                  style: TextStyle(
                    color: isPassing ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Histórico',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            FilledButton.icon(
              onPressed: () => _showAddGradeDialog(context, ref, subject, course),
              icon: const Icon(Icons.add),
              label: const Text('Lançar Nota'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (grades.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('Nenhuma nota lançada yet.'),
            ),
          )
        else
          ...grades.map(
            (grade) => Card(
              child: ListTile(
                title: Text(grade.name),
                subtitle: Text(
                  'Peso: ${grade.weight?.toStringAsFixed(1) ?? "1.0"} • ${DateFormat('dd/MM').format(grade.date)}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      grade.score.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), ''),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _showAddGradeDialog(context, ref, subject, course, gradeToEdit: grade),
                      tooltip: 'Editar',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                      onPressed: () => _confirmDelete(context, ref, subject, grade),
                      tooltip: 'Excluir',
                    ),
                  ],
                ),
                onTap: () => _showAddGradeDialog(context, ref, subject, course, gradeToEdit: grade),
              ),
            ),
          ),
      ],
    );
  }

  double _calculateAverage(List<GradeEntry> grades, WidgetRef ref) {
    if (grades.isEmpty) return 0.0;

    String? formulaToCheck;

    // 1. Check for Linked Scheme on the COURSE
    if (course.gradingSchemeId != null) {
      final schemes = ref.read(gradingSchemeProvider).asData?.value ?? [];
      final scheme = schemes
          .where((s) => s.key == course.gradingSchemeId)
          .firstOrNull;
      if (scheme != null) {
        formulaToCheck = scheme.formula;
      }
    }
    // 2. Check for legacy inline formula on subject
    else if (subject.gradingFormula != null &&
        subject.gradingFormula!.trim().isNotEmpty) {
      formulaToCheck = subject.gradingFormula!;
    }

    if (formulaToCheck != null) {
      try {
        final parser = Parser();
        final expression = parser.parse(formulaToCheck);
        final context = ContextModel();

        // Aggregate scores by tag
        final tagSums = <String, double>{};
        for (var g in grades) {
          if (g.tag != null && g.tag!.isNotEmpty) {
            tagSums[g.tag!] = (tagSums[g.tag!] ?? 0.0) + g.score;
          }
        }

        // Extract variables from formula to bind missing ones as 0.0
        final regExp = RegExp(r'[A-Za-z_][A-Za-z0-9_]*');
        final matches = regExp.allMatches(formulaToCheck);
        final variables = matches.map((m) => m.group(0)!).toSet().toList();
        variables.removeWhere((v) => ['sin', 'cos', 'tan', 'log', 'max', 'min', 'sqrt', 'pow'].contains(v));

        // Injetar variáveis (com lógica de substituição da P3 se existir)
        final p3Grade = grades.where((g) => g.tag?.toUpperCase() == 'P3').firstOrNull?.score;
        
        if (p3Grade != null) {
          // Encontrar qual variável tem a menor nota para substituir
          String? minVar;
          double minScore = double.infinity;
          
          for (var v in variables) {
            final score = tagSums[v] ?? 0.0;
            if (score < minScore) {
              minScore = score;
              minVar = v;
            }
          }
          
          if (minVar != null && p3Grade > minScore) {
            tagSums[minVar] = p3Grade;
          }
        }

        for (var v in variables) {
          context.bindVariable(Variable(v), Number(tagSums[v] ?? 0.0));
        }
        return expression.evaluate(EvaluationType.REAL, context);
      } catch (e) {
        debugPrint('Formula Error: $e');
        return 0.0;
      }
    }

    // 3. Fallback to Weighted Average
    double weightedSum = 0;
    double totalWeight = 0;
    for (var g in grades) {
      final w = g.weight ?? 1.0;
      weightedSum += g.score * w;
      totalWeight += w;
    }
    if (totalWeight == 0) return 0.0;
    return weightedSum / totalWeight;
  }

  Future<void> _showAddGradeDialog(
    BuildContext context,
    WidgetRef ref,
    Subject subject,
    Course course, {
    GradeEntry? gradeToEdit,
  }) async {
    final nameController = TextEditingController(text: gradeToEdit?.name);
    final scoreController = TextEditingController(text: gradeToEdit?.score.toString());
    final weightController = TextEditingController(text: gradeToEdit?.weight?.toString() ?? '1.0');
    final tagController = TextEditingController(text: gradeToEdit?.tag);

    // Extrair tags da fórmula para sugerir
    List<String> formulaTags = [];
    String? formulaToCheck;
    if (course.gradingSchemeId != null) {
      final schemes = ref.read(gradingSchemeProvider).asData?.value ?? [];
      final scheme = schemes.where((s) => s.key == course.gradingSchemeId).firstOrNull;
      if (scheme != null) formulaToCheck = scheme.formula;
    } else if (subject.gradingFormula != null && subject.gradingFormula!.trim().isNotEmpty) {
      formulaToCheck = subject.gradingFormula!;
    }

    if (formulaToCheck != null) {
      final regExp = RegExp(r'[A-Za-z_][A-Za-z0-9_]*');
      formulaTags = regExp.allMatches(formulaToCheck).map((m) => m.group(0)!).toSet().toList();
      formulaTags.removeWhere((v) => ['sin', 'cos', 'tan', 'log', 'max', 'min', 'sqrt', 'pow'].contains(v));
      
      // Sempre incluir P3 como opção de substituição se não estiver na fórmula
      if (!formulaTags.contains('P3')) {
        formulaTags.add('P3');
      }
    }

    final existingTags = subject.grades.map((g) => g.tag).whereType<String>().toSet();

    final result = await showDialog<GradeEntry>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(gradeToEdit == null ? 'Adicionar Nota' : 'Editar Nota'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome (ex: Prova)'),
              ),
              const SizedBox(height: 16),
              if (formulaTags.isNotEmpty) ...[
                DropdownMenu<String>(
                  controller: tagController,
                  label: const Text('Sigla/Tag (ex: P1)'),
                  helperText: 'Selecione a avaliação da fórmula',
                  dropdownMenuEntries: formulaTags.map((tag) {
                    final alreadyExists = existingTags.contains(tag) && (gradeToEdit == null || gradeToEdit.tag != tag);
                    return DropdownMenuEntry<String>(
                      value: tag, 
                      label: tag,
                      enabled: !alreadyExists,
                      style: MenuItemButton.styleFrom(
                        foregroundColor: alreadyExists ? Colors.grey : null,
                      ),
                    );
                  }).toList(),
                  onSelected: (value) {
                    if (value != null && nameController.text.isEmpty) {
                      nameController.text = value;
                    }
                  },
                ),
              ] else ...[
                TextField(
                  controller: tagController,
                  decoration: const InputDecoration(
                    labelText: 'Sigla/Tag (ex: P1)',
                    helperText: 'Usado na fórmula personalizada',
                  ),
                ),
              ],
              const SizedBox(height: 8),
              TextField(
                controller: scoreController,
                decoration: const InputDecoration(labelText: 'Nota (0 a 10)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(labelText: 'Peso'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final score = double.tryParse(scoreController.text);
              final weight = double.tryParse(weightController.text);
              if (score != null && weight != null) {
                if (gradeToEdit == null) {
                  Navigator.pop(
                    context,
                    GradeEntry()
                      ..name = nameController.text.isEmpty
                          ? 'Avaliação'
                          : nameController.text
                      ..tag = tagController.text.isEmpty
                          ? null
                          : tagController.text
                      ..score = score
                      ..weight = weight
                      ..date = DateTime.now(),
                  );
                } else {
                  // Edit existing
                  gradeToEdit.name = nameController.text.isEmpty ? 'Avaliação' : nameController.text;
                  gradeToEdit.tag = tagController.text.isEmpty ? null : tagController.text;
                  gradeToEdit.score = score;
                  gradeToEdit.weight = weight;
                  gradeToEdit.save(); // Save to Hive
                  Navigator.pop(context, gradeToEdit);
                }
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (result != null) {
      if (gradeToEdit == null) {
        ref.read(educationProvider.notifier).addGrade(subject.key, result);
      } else {
        ref.invalidate(educationProvider);
      }
    }
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Subject subject,
    GradeEntry grade,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Nota'),
        content: Text('Deseja excluir ${grade.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(educationProvider.notifier).deleteGrade(grade);
              Navigator.pop(ctx);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

class _CalculatorTab extends ConsumerStatefulWidget {
  final Subject subject;
  final Course course;

  const _CalculatorTab({required this.subject, required this.course});

  @override
  ConsumerState<_CalculatorTab> createState() => _CalculatorTabState();
}

class _CalculatorTabState extends ConsumerState<_CalculatorTab> {
  String? _formula;
  List<String> _variables = [];
  Map<String, double> _simulatedGrades = {};
  double? _p3Grade;
  
  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    // 1. Get formula from Course
    if (widget.course.gradingSchemeId != null) {
      final schemes = ref.read(gradingSchemeProvider).asData?.value ?? [];
      final scheme = schemes.where((s) => s.key == widget.course.gradingSchemeId).firstOrNull;
      if (scheme != null) _formula = scheme.formula;
    } else if (widget.subject.gradingFormula != null && widget.subject.gradingFormula!.trim().isNotEmpty) {
      _formula = widget.subject.gradingFormula!;
    }

    if (_formula != null) {
      // 2. Extract variables
      final regExp = RegExp(r'[A-Za-z_][A-Za-z0-9_]*');
      final matches = regExp.allMatches(_formula!);
      _variables = matches.map((m) => m.group(0)!).toSet().toList();
      // Remove math functions if accidentally matched
      _variables.removeWhere((v) => ['sin', 'cos', 'tan', 'log', 'max', 'min', 'sqrt', 'pow'].contains(v));

      // 3. Populate with existing grades
      for (var v in _variables) {
        double sum = 0;
        for (var g in widget.subject.grades) {
          if (g.tag == v) sum += g.score;
        }
        _simulatedGrades[v] = sum; // Default to 0 if no grade
      }
    }
  }

  double _calculateAverage() {
    if (_formula == null) return 0.0;
    try {
      final parser = Parser();
      final expression = parser.parse(_formula!);
      final context = ContextModel();

      for (var v in _variables) {
        double currentScore = _simulatedGrades[v] ?? 0.0;
        // P3 Substitution Logic in Simulator
        if (_p3Grade != null) {
          // Identify min var (simplified: the one with lowest simulated score)
          String? minVar;
          double minVal = double.infinity;
          for (var vari in _variables) {
            if ((_simulatedGrades[vari] ?? 0.0) < minVal) {
              minVal = _simulatedGrades[vari] ?? 0.0;
              minVar = vari;
            }
          }
          if (v == minVar && _p3Grade! > currentScore) {
            currentScore = _p3Grade!;
          }
        }
        context.bindVariable(Variable(v), Number(currentScore));
      }
      return expression.evaluate(EvaluationType.REAL, context);
    } catch (e) {
      return 0.0;
    }
  }

  double? _calculateNeededFor(String targetVariable) {
    if (_formula == null) return null;
    final passing = widget.subject.passingScore ?? 6.0;
    
    // Binary search to find the minimum score (0 to 10) needed to pass
    try {
      final parser = Parser();
      final expression = parser.parse(_formula!);
      
      double low = 0.0;
      double high = 10.0;
      double needed = -1.0;
      
      while (low <= high) {
        double mid = (low + high) / 2;
        final context = ContextModel();
        for (var v in _variables) {
          context.bindVariable(Variable(v), Number(v == targetVariable ? mid : (_simulatedGrades[v] ?? 0.0)));
        }
        final result = expression.evaluate(EvaluationType.REAL, context);
        
        if (result >= passing) {
          needed = mid;
          high = mid - 0.1; // Try to find a lower passing score
        } else {
          low = mid + 0.1;
        }
      }
      return needed >= 0 ? needed : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_formula == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('Nenhuma fórmula de avaliação vinculada. Configure uma fórmula primeiro para usar a calculadora.', textAlign: TextAlign.center),
        ),
      );
    }

    final average = _calculateAverage();
    final passing = widget.subject.passingScore ?? 6.0;
    final isPassing = average >= passing;
    
    double finalScore = average;
    bool isFinalPassing = isPassing;
    
    // P3 Logic (Exame Final)
    if (!isPassing && _p3Grade != null) {
      // Assuming standard "Média Final = (Média + Exame) / 2"
      finalScore = (average + _p3Grade!) / 2;
      isFinalPassing = finalScore >= passing; // Usually passing for final exam is 5.0, but keeping it dynamic
    }

    // Determine if any single field is currently 0, to show "how much needed"
    String? fieldNeedingScore;
    double? neededScore;
    if (!isPassing) {
      for (var v in _variables) {
        if ((_simulatedGrades[v] ?? 0.0) == 0.0) {
          final needed = _calculateNeededFor(v);
          if (needed != null && needed <= 10.0) {
            fieldNeedingScore = v;
            neededScore = needed;
            break; // Just show for the first empty field
          }
        }
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: isFinalPassing ? Colors.green.shade50 : Colors.red.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  _p3Grade != null ? 'Média Final (com P3)' : 'Média Simulada',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  finalScore.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: isFinalPassing ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isFinalPassing ? 'Aprovado' : (_p3Grade != null ? 'Reprovado' : 'Em Exame/Reprovado'),
                  style: TextStyle(
                    color: isFinalPassing ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        if (fieldNeedingScore != null && neededScore != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Você precisa tirar ${neededScore.toStringAsFixed(1)} em $fieldNeedingScore para passar direto!',
                    style: TextStyle(color: Colors.blue.shade900),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),
        const Text('Simular Notas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text('Deslize para ver como as notas afetam sua média.', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        
        ..._variables.map((v) {
          final val = _simulatedGrades[v] ?? 0.0;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(v, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(val.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), ''), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                ],
              ),
              Slider(
                value: val,
                min: 0,
                max: 10,
                divisions: 1000,
                label: val.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), ''),
                onChanged: (newValue) {
                  setState(() {
                    _simulatedGrades[v] = newValue;
                  });
                },
              ),
            ],
          );
        }),
        
        if (!isPassing) ...[
          const Divider(height: 32),
          const Text('Exame Final (P3)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('Sua média não atingiu o mínimo. Simule a P3 (Exame) para ver se passa.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Nota da P3', style: TextStyle(fontWeight: FontWeight.bold)),
              Text((_p3Grade ?? 0.0).toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), ''), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
            ],
          ),
          Slider(
            value: _p3Grade ?? 0.0,
            min: 0,
            max: 10,
            divisions: 1000,
            activeColor: Colors.orange,
            label: (_p3Grade ?? 0.0).toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), ''),
            onChanged: (newValue) {
              setState(() {
                _p3Grade = newValue;
              });
            },
          ),
        ],
      ],
    );
  }
}

class _NotesTab extends ConsumerWidget {
  final Subject subject;

  const _NotesTab({required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch subject updates
    final courses = ref.watch(educationProvider).asData?.value ?? [];
    Course? foundCourse;
    Subject? foundSubject;

    for (var c in courses) {
      for (var s in c.subjects) {
        if (s.key == subject.key) {
          foundCourse = c;
          foundSubject = s;
          break;
        }
      }
      if (foundSubject != null) break;
    }

    final currentSubject = foundSubject ?? subject;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (currentSubject.notes.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text("Nenhuma anotação.")),
          )
        else
          ...currentSubject.notes.map(
            (n) => Card(
              child: ListTile(
                title: Text(n),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    ref
                        .read(educationProvider.notifier)
                        .removeNote(currentSubject, n);
                  },
                ),
              ),
            ),
          ),

        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => _showAddNoteDialog(context, ref, currentSubject),
          icon: const Icon(Icons.add),
          label: const Text("Adicionar Anotação"),
        ),
      ],
    );
  }

  Future<void> _showAddNoteDialog(
    BuildContext context,
    WidgetRef ref,
    Subject subject,
  ) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Anotação'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Digite sua anotação...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref
                    .read(educationProvider.notifier)
                    .addNote(subject, controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}

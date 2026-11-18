# Round 7 — complexity survey

Measured **18 November 2026**, against `94bff06d0ec8c09790de0f7a1f1dbaed276d487f` before edits. **Result: a maintainability watchlist, with no demonstrated runtime defect or failing threshold.** No production refactor was made.

## Tool choice and scope

No `dcm`, `dart_code_metrics`, `dart-code-metrics`, `scc`, `cloc` or `lizard` executable was installed. DCM remains unrun. The [DCM metric reference](https://dcm.dev/docs/metrics/) describes complexity/nesting/size metrics, but this round uses a small read-only syntax survey through the app's already-resolved **analyzer 10.0.1**, Flutter **3.41.7** / Dart **3.11.5**. It installs nothing and does not configure a metrics gate. These are explicitly defined observations, not DCM scores or certified cyclomatic complexity.

The premeasurement scope includes **43 tracked runtime Dart files** under the three packages' `lib/` and server `bin/`: **19 authored**, **23 generated**, and **1 authored preview-support** file. Tests/tools are outside runtime scope. Generated server/client output and Widgetbook remain visible separately; the client barrel has no callable declaration. Parsing succeeded for all 43 files.

| Population | Files | Named/anonymous callable observations |
| --- | ---: | ---: |
| Authored runtime | 19 | 509 |
| Generated runtime | 23 | 464 |
| Preview support | 1 | 157 |

A callable is a function, method, getter/setter, constructor or anonymous function. Local functions/closures receive their own observations. Inclusive physical span includes comments, blank lines and nested callbacks; **spans overlap and must not be summed as file LOC**. Decision and nesting counts exclude nested callable bodies. Formal parameters include optional/named parameters and constructor field parameters, without weighting them.

Direct decision sites count `if`/collection-if, loops/collection-for, ternaries, each switch arm (including default), catch clauses, and `&&`, `||`, `??`. Maximum control nesting counts nested if/collection-if, loops/collection-for, switch statements/expressions and try nodes; it does not measure widget-tree depth. A fixture confirmed that comments/string text do not create decisions and a nested closure does not inflate its parent's decisions/nesting. This small fixture checks those semantics; it is not a third-party certification of the survey.

## Findings in plain English

The largest declarations mostly describe UI trees. A long widget builder can have few direct decisions because much behavior lives inside separately measured callbacks. The callback at `todo_app.dart:714` combines responsive layout, selection and panel policy; its 45 decision sites make it a useful review target. `featuredHomepageResults` has eight control levels while validating nested untrusted webpage data. Both are candidates for a focused simplification **when behavior is being changed**, with existing behavior tests preserved.

| Authored location / callable | Span lines | Direct decisions | Control nesting | Parameters |
| --- | ---: | ---: | ---: | ---: |
| [flutter_todo_flutter/lib/ui/task_details.dart:293](../../flutter_todo_flutter/lib/ui/task_details.dart#L293) `build` | 402 | 17 | 1 | 1 |
| [flutter_todo_flutter/lib/ui/task_list.dart:45](../../flutter_todo_flutter/lib/ui/task_list.dart#L45) `build` | 352 | 3 | 0 | 1 |
| [flutter_todo_flutter/lib/ui/sidebar.dart:54](../../flutter_todo_flutter/lib/ui/sidebar.dart#L54) `build` | 325 | 1 | 0 | 1 |
| [flutter_todo_flutter/lib/ui/todo_app.dart:714](../../flutter_todo_flutter/lib/ui/todo_app.dart#L714) `<closure>` | 221 | 45 | 1 | 2 |
| [flutter_todo_server/lib/src/background/unsplash_service.dart:422](../../flutter_todo_server/lib/src/background/unsplash_service.dart#L422) `featuredHomepageResults` | 57 | 25 | 8 | 1 |
| [flutter_todo_flutter/lib/ui/task_list.dart:75](../../flutter_todo_flutter/lib/ui/task_list.dart#L75) `<closure>` | 318 | 23 | 1 | 2 |
| [flutter_todo_server/lib/src/todo/todo_endpoint.dart:55](../../flutter_todo_server/lib/src/todo/todo_endpoint.dart#L55) `<closure>` | 67 | 14 | 4 | 1 |
| [flutter_todo_flutter/lib/services/backgrounds.dart:131](../../flutter_todo_flutter/lib/services/backgrounds.dart#L131) `_download` | 29 | 5 | 3 | 1 |
| [flutter_todo_flutter/lib/ui/task_list.dart:4](../../flutter_todo_flutter/lib/ui/task_list.dart#L4) `_TaskPane.` | 26 | 0 | 0 | 24 |
| [flutter_todo_flutter/lib/ui/sidebar.dart:4](../../flutter_todo_flutter/lib/ui/sidebar.dart#L4) `_Sidebar.` | 20 | 0 | 0 | 18 |
| [flutter_todo_flutter/lib/ui/task_details.dart:4](../../flutter_todo_flutter/lib/ui/task_details.dart#L4) `_TaskDetails.` | 11 | 0 | 0 | 9 |

The 24- and 18-parameter private widget constructors predominantly pass typed state/callbacks; their count alone does not establish a faulty interface. The parser deliberately guards serialized data and bounds its query/page/result loops. Inspection of these implementations found no new actionable correctness defect. Earlier coverage results are historical evidence of execution, not proof that every decision is correct. No suppression, complexity limit, automatic refactor or defect ticket was invented from a ranking.

Use this watchlist to concentrate review and focused tests when editing these areas. Before extracting a helper, name the behavior/responsibility it owns and preserve private-widget catalog coverage. A separate issue is appropriate if a concrete change or repeated maintenance problem is established; a numeric rank is insufficient by itself.

## Execution and reproduction

The recorded survey exited **0** in **2.738s** with empty stderr, a passing measurement fixture and all **337 tracked input hashes unchanged**. Raw JSON retains every callable, not just this table. No app test, native check or performance claim is inferred from this run.

Save the exact Dart appendix below to an ignored path such as `.dartnflutter/quality/metrics.dart`. Save a JSON scope object containing `all_runtime_files`, `primary_files` and `generated_files` arrays. Generate that inventory from tracked files: include each package's `lib/*.dart` recursively plus server `bin/*.dart`; classify client `lib/src/protocol/`, server `lib/src/generated/` and frontend `lib/widgetbook.dart` as generated, and frontend `lib/ui/catalog_previews.dart` as preview support. Inspect classification before measuring. From the repository root, run:

```sh
dart --packages=.dart_tool/package_config.json \
  .dartnflutter/quality/metrics.dart \
  .dartnflutter/quality/scope.json > .dartnflutter/quality/metrics.json
```

The workspace must already be resolved to the inspected compatible analyzer API; this report adds no direct analyzer dependency or general-purpose CLI promise. The retained premeasurement `scope.before.json` is the exact 43-file inventory used here.

Evidence: `.dartnflutter/quality/round-07-20261118T011141Z-94bff06d0ec8/` contains identity/scope, the exact runner, fixture result, argv/cwd/UTC/exit/timing, all tracked before/after SHA-256 manifests, full JSON and stderr. Survey JSON SHA-256: `e405fe6ed37dd013c61e96b7c2b1be5a441f119e44743a96ee5d470f8dd5c341`. Runner SHA-256: `d82a99de8372fd33ea4f1517e9d94bcb1aa878c83269a925d53a18fc40a87b67`. SDK, dependencies, production code, toolchain and `/dnf-*` skills were unchanged. Delivery review/PR records remain with the local evidence; [tracking](../trial/github-tracking.md) links the report.

## Exact observational runner

```dart
import 'dart:convert';
import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

List<Map<String, Object?>> measure(String source, String path) {
  final parsed = parseString(content: source, path: path, throwIfDiagnostics: false);
  if (parsed.errors.isNotEmpty) throw StateError('$path: ${parsed.errors}');
  final rows = <Map<String, Object?>>[];
  void add(AstNode root, String name, int parameters) {
    var decisions = 0;
    var maximum = 0;
    void visit(AstNode node, int depth) {
      if (!identical(node, root)) {
        if (node is MethodDeclaration || node is ConstructorDeclaration || node is FunctionDeclaration) return;
        if (node is FunctionExpression && !(root is FunctionDeclaration && identical(root.functionExpression, node))) return;
      }
      final control = node is IfStatement || node is IfElement || node is ForStatement || node is ForElement || node is WhileStatement || node is DoStatement || node is SwitchStatement || node is SwitchExpression || node is TryStatement;
      if (control) depth++;
      if (depth > maximum) maximum = depth;
      if (node is IfStatement || node is IfElement || node is ForStatement || node is ForElement || node is WhileStatement || node is DoStatement || node is ConditionalExpression || node is SwitchMember || node is SwitchExpressionCase || node is CatchClause) decisions++;
      if (node is BinaryExpression && ['&&', '||', '??'].contains(node.operator.lexeme)) decisions++;
      for (final child in node.childEntities.whereType<AstNode>()) { visit(child, depth); }
    }
    visit(root, 0);
    final line = parsed.lineInfo.getLocation(root.offset).lineNumber;
    final end = parsed.lineInfo.getLocation(root.end - 1).lineNumber;
    rows.add({'path': path, 'name': name, 'line': line, 'endLine': end, 'spanLines': end - line + 1, 'parameters': parameters, 'decisionSites': decisions, 'maximumControlNesting': maximum});
  }
  void collect(AstNode node) {
    if (node is MethodDeclaration) add(node, node.name.lexeme, node.parameters?.parameters.length ?? 0);
    if (node is ConstructorDeclaration) add(node, '${node.typeName?.name ?? 'new'}.${node.name?.lexeme ?? ''}', node.parameters.parameters.length);
    if (node is FunctionDeclaration) add(node, node.name.lexeme, node.functionExpression.parameters?.parameters.length ?? 0);
    if (node is FunctionExpression && node.parent is! FunctionDeclaration) add(node, '<closure>', node.parameters?.parameters.length ?? 0);
    for (final child in node.childEntities.whereType<AstNode>()) { collect(child); }
  }
  collect(parsed.unit);
  return rows;
}
void main(List<String> args) {
  final self = measure("void outer(bool a) { /* if && ? */ final text = 'if || ??'; if (a && text.isNotEmpty) { final f = () { if (a) return; }; f(); } }", 'fixture.dart');
  if (self.length != 2 || self[0]['decisionSites'] != 2 || self[0]['maximumControlNesting'] != 1 || self[0]['parameters'] != 1 || self[1]['decisionSites'] != 1 || self[1]['maximumControlNesting'] != 1) throw StateError('metric self-check failed: $self');
  final scope = jsonDecode(File(args[0]).readAsStringSync()) as Map<String, dynamic>;
  final rows = <Map<String, Object?>>[];
  for (final path in (scope['all_runtime_files'] as List).cast<String>()) {
    final group = (scope['primary_files'] as List).contains(path) ? 'authored' : (scope['generated_files'] as List).contains(path) ? 'generated' : 'preview-support';
    rows.addAll(measure(File(path).readAsStringSync(), path).map((row) => {...row, 'group': group}));
  }
  stdout.writeln(const JsonEncoder.withIndent('  ').convert({'selfCheck': 'passed: comments/strings ignored, nested closure isolated', 'files': (scope['all_runtime_files'] as List).length, 'callables': rows}));
}
```

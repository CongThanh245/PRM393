import 'dart:io';
import 'package:excel/excel.dart' as excel_pkg;
import 'package:file_picker/file_picker.dart';
import '../models/submission.dart';
import '../models/exam_type.dart';

class GradingExportService {
  Future<void> exportToExcel(
    List<Submission> submissions,
    String markerName,
  ) async {
    if (submissions.isEmpty) return;

    var excel = excel_pkg.Excel.createExcel();
    excel_pkg.Sheet sheetObject = excel['Sheet1'];

    // Find the active exam type from submissions
    var exam = submissions.first.examType ?? defaultExamTypes.first;

    // Group criteria by requirement
    List<RequirementGroup> reqGroups = [];
    String? currentReqKey;
    RequirementGroup? currentGroup;
    int fallbackCounter = 1;

    for (int i = 0; i < exam.criteria.length; i++) {
      final c = exam.criteria[i];
      final reqKey = c.requirementId ?? c.requirementTitle;

      if (reqKey != null) {
        if (currentReqKey != reqKey) {
          currentReqKey = reqKey;
          currentGroup = RequirementGroup(
            c.requirementTitle ?? c.requirementId!,
            0.0,
            [],
          );
          reqGroups.add(currentGroup);
        }
      } else {
        currentReqKey = null;
        currentGroup = RequirementGroup(
          c.name.isNotEmpty ? c.name : 'Question $fallbackCounter',
          0.0,
          [],
        );
        reqGroups.add(currentGroup);
        fallbackCounter++;
      }

      currentGroup!.maxScore10 += c.maxScore10;
      currentGroup.criterionIndices.add(i);
    }

    final int n = reqGroups.length;

    final headerStyle = excel_pkg.CellStyle(
      backgroundColorHex: excel_pkg.ExcelColor.fromHexString(
        '#FCE4D6',
      ), // soft peach
      horizontalAlign: excel_pkg.HorizontalAlign.Center,
      bold: true,
    );

    final totalStyle = excel_pkg.CellStyle(
      backgroundColorHex: excel_pkg.ExcelColor.fromHexString('#FCE4D6'),
      horizontalAlign: excel_pkg.HorizontalAlign.Center,
      bold: true,
      fontColorHex: excel_pkg.ExcelColor.fromHexString('#0000D3'), // blue color
    );

    final commentStyle = excel_pkg.CellStyle(
      backgroundColorHex: excel_pkg.ExcelColor.fromHexString(
        '#FFFF00',
      ), // bright yellow for Comment
      horizontalAlign: excel_pkg.HorizontalAlign.Center,
      bold: true,
    );

    final textCenterStyle = excel_pkg.CellStyle(
      horizontalAlign: excel_pkg.HorizontalAlign.Center,
    );

    // Row 0: empty A,B; Requirement titles in columns C onward, Total
    for (int i = 0; i < n; i++) {
      var cell = sheetObject.cell(
        excel_pkg.CellIndex.indexByColumnRow(columnIndex: i + 2, rowIndex: 0),
      );
      cell.value = excel_pkg.TextCellValue('Question ${i + 1}');
      cell.cellStyle = headerStyle;
    }
    var totalHeaderCell = sheetObject.cell(
      excel_pkg.CellIndex.indexByColumnRow(columnIndex: n + 2, rowIndex: 0),
    );
    totalHeaderCell.value = excel_pkg.TextCellValue('Total');
    totalHeaderCell.cellStyle = totalStyle;

    // Comment header in row 0 is REMOVED to match template

    // Row 1: Alias, Marker, max scores per question, SUM formula for total, Comment label
    var aliasCell = sheetObject.cell(
      excel_pkg.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
    );
    aliasCell.value = excel_pkg.TextCellValue('Alias');
    aliasCell.cellStyle = headerStyle;

    var markerCell = sheetObject.cell(
      excel_pkg.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1),
    );
    markerCell.value = excel_pkg.TextCellValue('Marker');
    markerCell.cellStyle = headerStyle;

    for (int i = 0; i < n; i++) {
      var cell = sheetObject.cell(
        excel_pkg.CellIndex.indexByColumnRow(columnIndex: i + 2, rowIndex: 1),
      );
      cell.value = excel_pkg.DoubleCellValue(reqGroups[i].maxScore10);
      cell.cellStyle = headerStyle;
    }

    // SUM formula for total (matching import format: =SUM(C2:F2) style)
    var totalFormulaCell = sheetObject.cell(
      excel_pkg.CellIndex.indexByColumnRow(columnIndex: n + 2, rowIndex: 1),
    );
    // Formula references data rows starting from row 3 (index 2), so this is row 2 which shows max scores
    // For import format compatibility, put max total score here instead of formula
    totalFormulaCell.value = excel_pkg.DoubleCellValue(exam.totalMaxScore10);
    totalFormulaCell.cellStyle = totalStyle;

    var commentLabelCell = sheetObject.cell(
      excel_pkg.CellIndex.indexByColumnRow(columnIndex: n + 3, rowIndex: 1),
    );
    commentLabelCell.value = excel_pkg.TextCellValue('Comment');
    commentLabelCell.cellStyle = commentStyle;

    // Row 2 onwards: Submissions
    for (int rowIndex = 0; rowIndex < submissions.length; rowIndex++) {
      final sub = submissions[rowIndex];
      sub.initScores(exam);

      // Alias - extract from filename
      final alias = _extractAliasFromFileName(sub.fileName);
      var aliasValCell = sheetObject.cell(
        excel_pkg.CellIndex.indexByColumnRow(
          columnIndex: 0,
          rowIndex: rowIndex + 2,
        ),
      );
      aliasValCell.value = excel_pkg.TextCellValue(alias);
      aliasValCell.cellStyle = textCenterStyle;

      // Marker Name - use individual submission marker or fallback to default markerName
      final submissionMarker = sub.marker ?? markerName;
      var markerValCell = sheetObject.cell(
        excel_pkg.CellIndex.indexByColumnRow(
          columnIndex: 1,
          rowIndex: rowIndex + 2,
        ),
      );
      markerValCell.value = excel_pkg.TextCellValue(submissionMarker);
      markerValCell.cellStyle = textCenterStyle;

      // Individual Requirement Scores
      for (int i = 0; i < n; i++) {
        double reqScore = 0.0;
        for (int cIndex in reqGroups[i].criterionIndices) {
          if (cIndex < sub.scores.length) {
            reqScore += sub.scores[cIndex];
          }
        }
        var scoreCell = sheetObject.cell(
          excel_pkg.CellIndex.indexByColumnRow(
            columnIndex: i + 2,
            rowIndex: rowIndex + 2,
          ),
        );
        scoreCell.value = excel_pkg.DoubleCellValue(reqScore);
        scoreCell.cellStyle = textCenterStyle;
      }

      // Total
      var totalValCell = sheetObject.cell(
        excel_pkg.CellIndex.indexByColumnRow(
          columnIndex: n + 2,
          rowIndex: rowIndex + 2,
        ),
      );
      totalValCell.value = excel_pkg.DoubleCellValue(sub.total);
      totalValCell.cellStyle = excel_pkg.CellStyle(
        horizontalAlign: excel_pkg.HorizontalAlign.Center,
        bold: true,
        fontColorHex: excel_pkg.ExcelColor.fromHexString('#0000D3'),
      );

      // Comment
      var commentValCell = sheetObject.cell(
        excel_pkg.CellIndex.indexByColumnRow(
          columnIndex: n + 3,
          rowIndex: rowIndex + 2,
        ),
      );
      commentValCell.value = excel_pkg.TextCellValue(sub.comment);
    }

    final bytes = excel.encode();
    if (bytes != null) {
      String? outputFile = await FilePicker.saveFile(
        dialogTitle: 'Export Excel',
        fileName: 'grading_results.xlsx',
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (outputFile != null) {
        if (!outputFile.endsWith('.xlsx')) {
          outputFile += '.xlsx';
        }
        final file = File(outputFile);
        await file.writeAsBytes(bytes);
      }
    }
  }

  String _extractAliasFromFileName(String fileName) {
    // Try to extract numeric alias from filename (e.g., "1.txt", "submission_2.txt", etc.)
    final nameWithoutExt = fileName.replaceAll(
      RegExp(r'\.[^.]+$'),
      '',
    ); // Remove extension
    final numbers = RegExp(
      r'\d+',
    ).allMatches(nameWithoutExt).map((m) => m.group(0)!).toList();

    if (numbers.isNotEmpty) {
      // Return the first number found as string
      return numbers.first;
    }

    // If no numbers found, try to match the filename directly as alias
    return nameWithoutExt.trim();
  }
}

class RequirementGroup {
  String title;
  double maxScore10;
  List<int> criterionIndices;

  RequirementGroup(this.title, this.maxScore10, this.criterionIndices);
}

import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart' as excel_pkg;
import '../models/exam_type.dart';
import '../models/submission.dart';

class FileService {
  Future<String?> pickAndExtractZip(String sessionId) async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (result != null && result.files.single.path != null) {
      final bytes = File(result.files.single.path!).readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);
      
      final appData = await getApplicationSupportDirectory();
      final extractPath = p.join(appData.path, 'PMG_Grader_Data', 'Extracted_$sessionId');
      
      print('====== ZIP STORAGE PATH ======');
      print(extractPath);
      print('==============================');
      
      // Clean existing directory first if they are re-uploading
      final dir = Directory(extractPath);
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
      
      for (final file in archive) {
        final filename = file.name;
        if (file.isFile && filename.endsWith('.txt')) {
          final data = file.content as List<int>;
          final outFile = File(p.join(extractPath, filename));
          outFile.createSync(recursive: true);
          outFile.writeAsBytesSync(data);
        }
      }
      return extractPath;
    }
    return null;
  }

  Future<String?> extractZipFromPath(String zipFilePath, String sessionId) async {
    try {
      final appData = await getApplicationSupportDirectory();
      final extractPath = p.join(appData.path, 'PMG_Grader_Data', 'Extracted_$sessionId');

      print('====== EXTRACT PATH ======');
      print(extractPath);
      print('==========================');

      // Check if folder already exists and has text files. If so, just return it without re-extracting!
      final dir = Directory(extractPath);
      if (dir.existsSync()) {
        final files = dir.listSync(recursive: true).where((file) => p.extension(file.path) == '.txt').toList();
        if (files.isNotEmpty) {
          return extractPath;
        }
      }

      final bytes = File(zipFilePath).readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);

      for (final file in archive) {
        final filename = file.name;
        if (file.isFile && filename.endsWith('.txt')) {
          final data = file.content as List<int>;
          final outFile = File(p.join(extractPath, filename));
          outFile.createSync(recursive: true);
          outFile.writeAsBytesSync(data);
        }
      }
      return extractPath;
    } catch (e) {
      return null;
    }
  }

  List<Submission> loadSubmissionsFromFolder(String path) {
    final dir = Directory(path);
    final files = dir.listSync(recursive: true).where((file) => p.extension(file.path) == '.txt').toList();

    List<Submission> loadedSubmissions = [];
    for (var file in files) {
      if (file is File) {
        final content = file.readAsStringSync();
        loadedSubmissions.add(Submission(
          fileName: p.basename(file.path),
          filePath: file.path,
          content: content,
        ));
      }
    }
    loadedSubmissions.sort((a, b) {
      // Extract numbers from filenames for proper ordering
      final extractNumber = (String fileName) {
        final numbers = RegExp(r'\d+').allMatches(fileName).map((m) => m.group(0)!).toList();
        if (numbers.isNotEmpty) {
          return int.tryParse(numbers.first) ?? 0;
        }
        return 0;
      };
      
      final numA = extractNumber(a.fileName);
      final numB = extractNumber(b.fileName);
      
      return numA.compareTo(numB);
    });
    return loadedSubmissions;
  }

  Future<String?> extractDocxTextFromPath(String path) async {
    try {
      final bytes = File(path).readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);
      
      final docFile = archive.firstWhere(
        (file) => file.name == 'word/document.xml',
        orElse: () => throw Exception('Invalid DOCX format: word/document.xml not found'),
      );
      
      final xmlContent = utf8.decode(docFile.content as List<int>);
      
      final buffer = StringBuffer();
      final regExp = RegExp(r'<[^>]+>|[^<]+');
      final matches = regExp.allMatches(xmlContent);
      
      bool inText = false;
      
      for (final match in matches) {
        final token = match.group(0)!;
        if (token.startsWith('<')) {
          final tagName = token.toLowerCase();
          if (tagName == '<w:t>' || tagName.startsWith('<w:t ')) {
            inText = true;
          } else if (tagName == '</w:t>') {
            inText = false;
          } else if (tagName == '<w:p>' || tagName.startsWith('<w:p ')) {
            // New paragraph, ensure a newline
            final current = buffer.toString();
            if (current.isNotEmpty && !current.endsWith('\n')) {
              buffer.write('\n');
            }
          } else if (tagName == '<w:tr>' || tagName.startsWith('<w:tr ')) {
            // Table row separator
            final current = buffer.toString();
            if (current.isNotEmpty && !current.endsWith('\n')) {
              buffer.write('\n');
            }
          } else if (tagName == '<w:tc>' || tagName.startsWith('<w:tc ')) {
            // Table column cell separator
            buffer.write('\t');
          } else if (tagName.contains('w:br')) {
            buffer.write('\n');
          } else if (tagName.contains('w:tab')) {
            buffer.write('\t');
          }
        } else {
          if (inText) {
            buffer.write(token);
          }
        }
      }
      
      String text = buffer.toString()
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>')
          .replaceAll('&amp;', '&')
          .replaceAll('&quot;', '"')
          .replaceAll('&apos;', "'");
          
      // Clean up whitespace and collapse multiple empty lines
      final lines = text.split('\n');
      final cleanLines = <String>[];
      for (var line in lines) {
        final trimmed = line.trim();
        if (trimmed.isNotEmpty) {
          cleanLines.add(trimmed);
        }
      }
      
      return cleanLines.join('\n');
    } catch (e) {
      throw Exception("Failed to parse Word document: $e");
    }
  }

  Future<String?> pickAndParseDocx() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['docx'],
    );

    if (result != null && result.files.single.path != null) {
      return extractDocxTextFromPath(result.files.single.path!);
    }
    return null;
  }

  List<Criterion> parseImportRubricCriteria(String text) {
    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    final criteria = <Criterion>[];
    String? currentRequirementId;
    String? currentRequirementTitle;
    Map<String, String>? currentCriterion;
    List<String> currentCommonErrors = [];

    void flushCriterion() {
      if (currentCriterion == null) return;
      final title = currentCriterion!['title'];
      final pointsText = currentCriterion!['max_points'];
      if (title != null && pointsText != null) {
        criteria.add(Criterion(
          title,
          double.tryParse(pointsText.replaceAll(',', '.')) ?? 0.0,
          id: currentCriterion!['id'],
          requirementId: currentRequirementId,
          requirementTitle: currentRequirementTitle,
          fullDescription: currentCriterion!['level_full_description'],
          partialDescription: currentCriterion!['level_partial_description'],
          failDescription: currentCriterion!['level_fail_description'],
          commonErrors: currentCommonErrors.isNotEmpty ? List.from(currentCommonErrors) : null,
        ));
      }
      currentCriterion = null;
      currentCommonErrors = [];
    }

    for (final line in lines) {
      if (line.startsWith('[') && line.endsWith(']')) {
        final marker = line.substring(1, line.length - 1);
        if (marker == 'REQUIREMENT') {
          flushCriterion();
          currentRequirementId = null;
          currentRequirementTitle = null;
          currentCommonErrors = [];
        } else if (marker == 'CRITERION') {
          flushCriterion();
          currentCriterion = <String, String>{};
        } else if (marker == 'COMMON_ERRORS') {
          flushCriterion();
          currentCommonErrors = [];
        } else {
          flushCriterion();
        }
        continue;
      }

      final separatorIndex = line.indexOf('=');
      if (separatorIndex <= 0) continue;
      final key = line.substring(0, separatorIndex).trim();
      final value = line.substring(separatorIndex + 1).trim();

      if (key.startsWith('error_')) {
        currentCommonErrors.add(value);
      } else if (currentCriterion != null) {
        currentCriterion![key] = value;
      } else {
        if (key == 'id') currentRequirementId = value;
        if (key == 'title') currentRequirementTitle = value;
      }
    }

    flushCriterion();
    return criteria;
  }

  Future<String?> extractMarkerName(String path) async {
    try {
      final bytes = File(path).readAsBytesSync();
      var excel = excel_pkg.Excel.decodeBytes(bytes);
      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table];
        if (sheet == null || sheet.maxRows == 0) continue;
        
        // Find "Marker" column index
        int markerColIndex = -1;
        final searchLimit = sheet.maxRows > 5 ? 5 : sheet.maxRows;
        for (int r = 0; r < searchLimit; r++) {
          final row = sheet.rows[r];
          for (int c = 0; c < row.length; c++) {
            final val = row[c]?.value?.toString().trim().toLowerCase();
            if (val == 'marker' || val == 'người chấm' || val == 'nguoi cham') {
              markerColIndex = c;
              break;
            }
          }
          if (markerColIndex != -1) {
            // Find first non-empty value below this header
            for (int r2 = r + 1; r2 < sheet.maxRows; r2++) {
              if (markerColIndex < sheet.rows[r2].length) {
                final cellVal = sheet.rows[r2][markerColIndex]?.value?.toString().trim();
                if (cellVal != null && cellVal.isNotEmpty) {
                  return cellVal;
                }
              }
            }
          }
        }
        
        // Fallback: look at column 1 (index 1), row 2 (index 2) onwards
        for (int r = 2; r < sheet.maxRows; r++) {
          if (sheet.rows[r].length > 1) {
            final cellVal = sheet.rows[r][1]?.value?.toString().trim();
            if (cellVal != null && cellVal.isNotEmpty) {
              return cellVal;
            }
          }
        }
      }
    } catch (e) {
      // Ignore or log error
    }
    return null;
  }

  Future<Map<String, String>> extractAliasMarkerMappings(String path) async {
    final Map<String, String> mappings = {};
    try {
      final bytes = File(path).readAsBytesSync();
      var excel = excel_pkg.Excel.decodeBytes(bytes);
      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table];
        if (sheet == null || sheet.maxRows == 0) continue;
        
        // Find column indices for "Alias" and "Marker"
        int aliasColIndex = -1;
        int markerColIndex = -1;
        int headerRow = -1;
        
        final searchLimit = sheet.maxRows > 5 ? 5 : sheet.maxRows;
        for (int r = 0; r < searchLimit; r++) {
          final row = sheet.rows[r];
          bool foundAlias = false;
          bool foundMarker = false;
          
          for (int c = 0; c < row.length; c++) {
            final val = row[c]?.value?.toString().trim().toLowerCase();
            if (val == 'alias') {
              aliasColIndex = c;
              foundAlias = true;
            } else if (val == 'marker' || val == 'người chấm' || val == 'nguoi cham') {
              markerColIndex = c;
              foundMarker = true;
            }
          }
          
          if (foundAlias && foundMarker) {
            headerRow = r;
            break;
          }
        }
        
        // If both columns found, extract mappings
        if (aliasColIndex != -1 && markerColIndex != -1 && headerRow != -1) {
          for (int r = headerRow + 1; r < sheet.maxRows; r++) {
            final row = sheet.rows[r];
            if (row.length > (aliasColIndex > markerColIndex ? aliasColIndex : markerColIndex)) {
              final alias = row[aliasColIndex]?.value?.toString().trim();
              final marker = row[markerColIndex]?.value?.toString().trim();
              
              if (alias != null && alias.isNotEmpty && 
                  marker != null && marker.isNotEmpty) {
                mappings[alias] = marker;
              }
            }
          }
        }
      }
    } catch (e) {
      // Ignore or log error
    }
    return mappings;
  }

  Future<Map<String, int>> extractMarkerWorkload(String path) async {
    final Map<String, int> workload = {};
    try {
      final bytes = File(path).readAsBytesSync();
      var excel = excel_pkg.Excel.decodeBytes(bytes);
      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table];
        if (sheet == null || sheet.maxRows == 0) continue;

        // Find "Marker" column index
        int markerColIndex = -1;
        int headerRow = -1;

        final searchLimit = sheet.maxRows > 5 ? 5 : sheet.maxRows;
        for (int r = 0; r < searchLimit; r++) {
          final row = sheet.rows[r];
          for (int c = 0; c < row.length; c++) {
            final val = row[c]?.value?.toString().trim().toLowerCase();
            if (val == 'marker' || val == 'người chấm' || val == 'nguoi cham') {
              markerColIndex = c;
              headerRow = r;
              break;
            }
          }
          if (markerColIndex != -1) break;
        }

        // If marker column found, count workload
        if (markerColIndex != -1 && headerRow != -1) {
          for (int r = headerRow + 1; r < sheet.maxRows; r++) {
            final row = sheet.rows[r];
            if (row.length > markerColIndex) {
              final marker = row[markerColIndex]?.value?.toString().trim();
              if (marker != null && marker.isNotEmpty) {
                workload[marker] = (workload[marker] ?? 0) + 1;
              }
            }
          }
        }
      }
    } catch (e) {
      // Ignore or log error
    }
    return workload;
  }

  Future<List<String>> extractMarkersList(String path) async {
    final Set<String> markers = {};
    try {
      final bytes = File(path).readAsBytesSync();
      var excel = excel_pkg.Excel.decodeBytes(bytes);
      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table];
        if (sheet == null || sheet.maxRows == 0) continue;

        // Find "Marker" column index
        int markerColIndex = -1;
        int headerRow = -1;

        final searchLimit = sheet.maxRows > 5 ? 5 : sheet.maxRows;
        for (int r = 0; r < searchLimit; r++) {
          final row = sheet.rows[r];
          for (int c = 0; c < row.length; c++) {
            final val = row[c]?.value?.toString().trim().toLowerCase();
            if (val == 'marker' || val == 'người chấm' || val == 'nguoi cham') {
              markerColIndex = c;
              headerRow = r;
              break;
            }
          }
          if (markerColIndex != -1) break;
        }

        // If marker column found, extract unique markers
        if (markerColIndex != -1 && headerRow != -1) {
          for (int r = headerRow + 1; r < sheet.maxRows; r++) {
            final row = sheet.rows[r];
            if (row.length > markerColIndex) {
              final marker = row[markerColIndex]?.value?.toString().trim();
              if (marker != null && marker.isNotEmpty) {
                markers.add(marker);
              }
            }
          }
        }
      }
    } catch (e) {
      // Ignore or log error
    }
    return markers.toList()..sort();
  }
}

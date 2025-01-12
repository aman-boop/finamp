import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:clipboard/clipboard.dart';
import 'package:finamp/services/censored_log.dart';
import 'package:finamp/services/metadata_helper.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path_helper;
import 'package:hive/hive.dart';

class FinampLogsHelper {
  final List<LogRecord> logs = [];
  late final Box logBox;

  FinampLogsHelper() {
    _initializeLogBox();
  }

  Future<void> _initializeLogBox() async {
    logBox = await Hive.openBox('logs');
  }

  Future<void> openLog() async {
    await _initializeLogBox();
  }

  void addLog(LogRecord log) {
    logs.add(log);

    // We don't want to keep logs forever due to memory constraints.
    if (logs.length > 1000) {
      logs.removeAt(0);
    }

    // Write log to Hive box
    logBox.add(log.censoredMessage);
  }

  /// Sanitises all logs and returns a massive string
  String getSanitisedLogs() {
    final logsStringBuffer = StringBuffer();

    for (final log in logs) {
      logsStringBuffer.writeln(log.censoredMessage);
    }

    return logsStringBuffer.toString();
  }

  Future<void> copyLogs() async =>
      await FlutterClipboard.copy(getSanitisedLogs());

  /// Write logs to a file and share the file
  Future<void> shareLogs() async {
    final tempDir = await getTemporaryDirectory();
    final zipFile = File(path_helper.join(tempDir.path, "finamp-logs.zip"));

    // Create a zip encoder
    final encoder = ZipFileEncoder();
    encoder.create(zipFile.path);

    // Add log file to the zip
    final logFile = File(path_helper.join(tempDir.path, "finamp-logs.txt"));
    await logFile.writeAsString(getSanitisedLogs());
    encoder.addFile(logFile);

    // Add metadata.json to the zip
    final metadata = getIt<MetaData>();
    await metadata.init();
    final metadataFile = File(path_helper.join(tempDir.path, "metadata.json"));
    await metadataFile.writeAsString(metadata.toJson().toString());
    encoder.addFile(metadataFile);

    // Close the zip encoder
    encoder.close();

    // Share the zip file
    final xFile = XFile(zipFile.path, mimeType: "application/zip");
    await Share.shareXFiles([xFile]);

    // Clean up temporary files
    await metadataFile.delete();
    await zipFile.delete();
  }
}

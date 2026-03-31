import 'package:flutter/foundation.dart';

/// A single history record.
class HistoryRecord {
  final DateTime timestamp;
  final String recipeName;
  final String result;
  final String operatorName;

  const HistoryRecord({
    required this.timestamp,
    required this.recipeName,
    required this.result,
    required this.operatorName,
  });
}

/// Controller for the History screen.
class HistoryController extends ChangeNotifier {
  List<HistoryRecord> _records = [];
  List<HistoryRecord> get records => _records;

  String _resultFilter = 'All';
  String get resultFilter => _resultFilter;

  HistoryController() {
    _loadMockData();
  }

  void setResultFilter(String filter) {
    _resultFilter = filter;
    notifyListeners();
  }

  List<HistoryRecord> get filteredRecords {
    if (_resultFilter == 'All') return _records;
    return _records.where((r) => r.result == _resultFilter).toList();
  }

  void _loadMockData() {
    final now = DateTime.now();
    _records = List.generate(20, (i) {
      return HistoryRecord(
        timestamp: now.subtract(Duration(minutes: i * 12)),
        recipeName: i.isEven ? 'Standard PVC 6mm' : 'Standard PVC 8mm',
        result: i % 5 == 0 ? 'Fail' : 'Pass',
        operatorName: 'Operator ${(i % 3) + 1}',
      );
    });
  }
}

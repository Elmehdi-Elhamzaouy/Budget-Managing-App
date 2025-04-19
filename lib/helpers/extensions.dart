extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

extension DoubleListExtensions on List<double> {
  double get average => isEmpty ? 0 : reduce((a, b) => a + b) / length;
}

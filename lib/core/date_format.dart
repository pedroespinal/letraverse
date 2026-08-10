const _monthsEs = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

const _monthsEn = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// Small self-contained date formatter (no ICU locale-data dependency) so
/// the genesis date on the About screen never depends on intl's locale
/// initialization order.
String formatLongDate(DateTime date, String langCode) {
  final months = langCode == 'es' ? _monthsEs : _monthsEn;
  final month = months[date.month - 1];
  if (langCode == 'es') {
    return '${date.day} de $month de ${date.year}';
  }
  return '$month ${date.day}, ${date.year}';
}

String thousand(num value) {
  final negative = value < 0;
  final source = value.abs().round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < source.length; i++) {
    if (i > 0 && (source.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(source[i]);
  }
  return negative ? '-$buffer' : buffer.toString();
}

String decimal(num value) {
  final rounded = value.toStringAsFixed(1);
  return rounded.replaceAll('.', ',');
}

String dayShort(DateTime date) {
  const labels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  return labels[date.weekday - 1];
}

String timeLabel(String raw) {
  final parts = raw.split(':');
  if (parts.length < 2) {
    return raw;
  }
  return '${parts[0].padLeft(2, '0')}.${parts[1].padLeft(2, '0')}';
}

String formatDateId(DateTime date) {
  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

enum HistoryFilterStatus {
  all('Semua'),
  active('Aktif'),
  completed('Selesai'),
  rejected('Ditolak');

  const HistoryFilterStatus(this.label);
  final String label;
}

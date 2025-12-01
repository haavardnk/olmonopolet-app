bool isHolidaySeason() {
  final month = DateTime.now().month;
  return month == 11 || month == 12;
}

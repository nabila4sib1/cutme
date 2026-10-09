// ============================================================
// HELPER
// ============================================================
//
// Kumpulan fungsi bantu untuk membaca response API yang
// bentuknya bisa bermacam-macam (List langsung, atau dibungkus
// {"data": ...}).

List<dynamic> extractList(dynamic response) {
  if (response is List) {
    return response;
  }

  if (response is Map) {
    final data = response['data'];

    if (data is List) {
      return data;
    }

    if (data is Map) {
      return [data];
    }
  }

  return [];
}

Map<String, dynamic> extractMap(dynamic response) {
  if (response is Map<String, dynamic>) {
    final data = response['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    return response;
  }

  return {};
}

int getId(dynamic item, List<String> keys) {
  if (item is! Map) return 0;

  for (final key in keys) {
    final value = item[key];

    if (value != null) {
      return int.tryParse(value.toString()) ?? 0;
    }
  }

  return 0;
}

String getString(
  dynamic item,
  List<String> keys, {
  String defaultValue = '-',
}) {
  if (item is! Map) return defaultValue;

  for (final key in keys) {
    final value = item[key];

    if (value != null && value.toString().isNotEmpty) {
      return value.toString();
    }
  }

  return defaultValue;
}

double getDouble(dynamic item, List<String> keys) {
  if (item is! Map) return 0;

  for (final key in keys) {
    final value = item[key];

    if (value != null) {
      return double.tryParse(value.toString()) ?? 0;
    }
  }

  return 0;
}
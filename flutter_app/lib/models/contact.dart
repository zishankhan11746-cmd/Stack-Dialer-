class ContactModel {
  final String id;
  final String name;
  final String number;
  final String? company;
  final bool isFavorite;

  ContactModel({
    required this.id,
    required this.name,
    required this.number,
    this.company,
    this.isFavorite = false,
  });

  String get initials {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}

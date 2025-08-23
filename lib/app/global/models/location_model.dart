class SelectedLocation {
  final String name;
  final double latitude;
  final double longitude;
  final String? address;

  SelectedLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }

  factory SelectedLocation.fromMap(Map<String, dynamic> map) {
    return SelectedLocation(
      name: map['name'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      address: map['address'],
    );
  }
}

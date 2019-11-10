class Contact {
  String address;
  String notes;
  String name;

  Contact(this.address, this.name, this.notes);

  Contact.fromJson(Map<String, dynamic> data)
      : address = data['address'],
        notes = data['notes'],
        name = data['name'];

  Map<String, dynamic> toJson() => {
        'address': address,
        'notes': notes,
        'name': name,
      };
}

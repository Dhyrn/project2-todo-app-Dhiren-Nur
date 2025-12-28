class Attachment {
  final String url;
  final String name;
  final String type;
  final int size;

  Attachment({
    required this.url,
    required this.name,
    required this.type,
    required this.size,
  });

  factory Attachment.fromMap(Map<String, dynamic> map) {
    return Attachment(
      url: map['url'],
      name: map['name'],
      type: map['type'],
      size: map['size'],
    );
  }

  Map<String, dynamic> toMap() => {
    'url': url,
    'name': name,
    'type': type,
    'size': size,
  };
}
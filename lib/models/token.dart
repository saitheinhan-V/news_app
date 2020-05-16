
class Token{
  final int id;
  final String value;

  Token(this.id, this.value);

  static final columns = ["id", "value"];

  factory Token.fromMap(Map<String, dynamic> data) {
    return Token(
      data['id'],
      data['value'],
    );
  }
  Map<String, dynamic> toMap() => {
    "id": id,
    "value": value,
  };
}
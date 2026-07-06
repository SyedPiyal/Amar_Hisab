import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'shop.g.dart';

@HiveType(typeId: 12)
class Shop extends Equatable {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String addressLine1;
  @HiveField(2)
  final String addressLine2;
  @HiveField(3)
  final String phoneNumber;
  @HiveField(4)
  final String emailAddress;
  @HiveField(5)
  final String footerText;

  const Shop({
    this.name = '',
    this.addressLine1 = '',
    this.addressLine2 = '',
    this.phoneNumber = '',
    this.emailAddress = '',
    this.footerText = '',
  });

  Shop copyWith({
    String? name,
    String? addressLine1,
    String? addressLine2,
    String? phoneNumber,
    String? emailAddress,
    String? footerText,
  }) {
    return Shop(
      name: name ?? this.name,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailAddress: emailAddress ?? this.emailAddress,
      footerText: footerText ?? this.footerText,
    );
  }

  @override
  List<Object?> get props =>
      [name, addressLine1, addressLine2, phoneNumber, emailAddress, footerText];
}

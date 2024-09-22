import 'package:equatable/equatable.dart';

class PDC extends Equatable {
  final String data;
  final int count;

  const PDC({required this.data, required this.count});
  @override
  List<Object?> get props => [data, count];
}

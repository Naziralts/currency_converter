import 'package:equatable/equatable.dart';


abstract class ConverterEvent extends Equatable {
  const ConverterEvent();


  @override
  List<Object?> get props => [];
}


class ConverterInit extends ConverterEvent {
  const ConverterInit();
}

class ConverterBaseChanged extends ConverterEvent {
  final String base; 

  const ConverterBaseChanged(this.base);

  @override
  List<Object?> get props => [base]; 
}


class ConverterTargetChanged extends ConverterEvent {
  final String target; 

  const ConverterTargetChanged(this.target);

  @override
  List<Object?> get props => [target]; 
}

class ConverterAmountChanged extends ConverterEvent {
  final String amountText; 

  const ConverterAmountChanged(this.amountText);

  @override
  List<Object?> get props => [amountText];
}


class ConverterConvertPressed extends ConverterEvent {
  const ConverterConvertPressed();
}

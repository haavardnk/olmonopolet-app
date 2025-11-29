import 'package:flutter/material.dart';
import './first_page_exception_indicator.dart';

class FirstPageErrorIndicator extends StatelessWidget {
  const FirstPageErrorIndicator({
    this.onTryAgain,
    super.key,
  });

  final VoidCallback? onTryAgain;

  @override
  Widget build(BuildContext context) => FirstPageExceptionIndicator(
        title: 'Noe gikk galt',
        message: 'En ukjent feil har oppstått.\n'
            'Vennligst forsøk igjen senere.',
        onTryAgain: onTryAgain,
      );
}

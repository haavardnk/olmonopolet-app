import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './first_page_exception_indicator.dart';

class NoItemsFoundIndicator extends StatelessWidget {
  const NoItemsFoundIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) => const FirstPageExceptionIndicator(
        title: 'Ingen produkter funnet',
        message: 'Listen er for øyeblikket tom.',
      );
}

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../models/store.dart';

class _TheState {}

var _theState = RM.inject(() => _TheState());

class _SelectRow extends StatelessWidget {
  final Function(bool) onChange;
  final bool selected;
  final Store store;
  final String text;

  const _SelectRow(
      {Key? key,
      required this.onChange,
      required this.selected,
      required this.store,
      required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          activeColor: Colors.pink,
          value: selected,
          onChanged: (x) {
            onChange(x!);
            _theState.notify();
          },
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(text)),
              if (store.distance != null)
                Text((store.distance! / 1000).toStringAsFixed(1) + 'km'),
            ],
          ),
        )
      ],
    );
  }
}

class DropDownMultiSelect extends StatefulWidget {
  final List<String> options;
  final List<Store> stores;
  final List<String> selectedValues;
  final Function(List<String>) onChanged;
  final String? whenEmpty;

  const DropDownMultiSelect({
    Key? key,
    required this.options,
    required this.stores,
    required this.selectedValues,
    required this.onChanged,
    required this.whenEmpty,
  }) : super(key: key);

  @override
  _DropDownMultiSelectState createState() => _DropDownMultiSelectState();
}

class _DropDownMultiSelectState extends State<DropDownMultiSelect> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: Stack(
        children: [
          _theState.rebuild(
            () => Align(
              child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                  child: Text(
                    widget.selectedValues.length > 0
                        ? widget.selectedValues.reduce((a, b) => a + ', ' + b)
                        : widget.whenEmpty ?? '',
                    style: TextStyle(fontSize: 16),
                  )),
              alignment: Alignment.centerLeft,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: DropdownButtonFormField<String>(
              menuMaxHeight: MediaQuery.of(context).size.height * 0.6,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 10,
                ),
              ),
              isDense: true,
              onChanged: (x) {},
              value: widget.selectedValues.length > 0
                  ? widget.selectedValues[0]
                  : null,
              selectedItemBuilder: (context) {
                return widget.options
                    .map((e) => DropdownMenuItem(
                          child: Container(),
                        ))
                    .toList();
              },
              items: widget.options
                  .map(
                    (x) => DropdownMenuItem(
                      child: _theState.rebuild(
                        () {
                          return _SelectRow(
                            selected: widget.selectedValues.contains(x),
                            text: x,
                            store: widget.stores
                                .firstWhere((element) => element.name == x),
                            onChange: (isSelected) {
                              if (isSelected) {
                                var ns = widget.selectedValues;
                                ns.add(x);
                                widget.onChanged(ns);
                              } else {
                                var ns = widget.selectedValues;
                                ns.remove(x);
                                widget.onChanged(ns);
                              }
                            },
                          );
                        },
                      ),
                      value: x,
                      onTap: () {
                        if (widget.selectedValues.contains(x)) {
                          var ns = widget.selectedValues;
                          ns.remove(x);
                          widget.onChanged(ns);
                        } else {
                          var ns = widget.selectedValues;
                          ns.add(x);
                          widget.onChanged(ns);
                        }
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

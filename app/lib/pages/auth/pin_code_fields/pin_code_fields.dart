import 'package:flutter/material.dart';

enum PinCodeFieldShape { box, underline }

class PinTheme {
  final double fieldHeight;
  final double fieldWidth;
  final double borderWidth;
  final BorderRadius borderRadius;
  final PinCodeFieldShape shape;
  final Color activeColor;
  final Color inactiveColor;
  final Color selectedColor;

  const PinTheme({
    this.fieldHeight = 50.0,
    this.fieldWidth = 40.0,
    this.borderWidth = 2.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.shape = PinCodeFieldShape.box,
    this.activeColor = Colors.black,
    this.inactiveColor = Colors.grey,
    this.selectedColor = Colors.blue,
  });
}

class PinCodeTextField extends StatefulWidget {
  final BuildContext appContext;
  final int length;
  final TextStyle textStyle;
  final MainAxisAlignment mainAxisAlignment;
  final bool enableActiveFill;
  final bool autoFocus;
  final bool enablePinAutofill;
  final double errorTextSpace;
  final bool showCursor;
  final Color cursorColor;
  final TextInputType keyboardType;
  final String hintCharacter;
  final PinTheme pinTheme;
  final TextEditingController controller;
  final Function(String) onChanged;

  const PinCodeTextField({
    super.key,
    required this.appContext,
    required this.length,
    required this.textStyle,
    required this.controller,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.enableActiveFill = false,
    this.autoFocus = false,
    this.enablePinAutofill = false,
    this.errorTextSpace = 16.0,
    this.showCursor = true,
    this.cursorColor = Colors.blue,
    this.keyboardType = TextInputType.number,
    this.hintCharacter = '',
    this.pinTheme = const PinTheme(),
    required this.onChanged,
  });

  @override
  _PinCodeTextFieldState createState() => _PinCodeTextFieldState();
}

class _PinCodeTextFieldState extends State<PinCodeTextField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();

    // Initialize controllers and focus nodes
    _controllers = List.generate(
      widget.length,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(widget.length, (_) => FocusNode());

    // Sync the external controller's text
    widget.controller.addListener(() {
      if (mounted) {
        setState(() {
          final text = widget.controller.text;
          for (int i = 0; i < widget.length; i++) {
            _controllers[i].text = i < text.length ? text[i] : '';
          }
        });
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (value.length == 1) {
        widget.controller.text = _updateControllerText(index, value);
        if (index < widget.length - 1) {
          FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
        }
      } else {
        // Trim to the last character entered
        _controllers[index].text = value.substring(value.length - 1);
      }
    } else {
      // Move focus to the previous field on delete
      if (index > 0) {
        FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
      }
    }
    widget.onChanged(widget.controller.text);
  }

  String _updateControllerText(int index, String value) {
    final currentText = widget.controller.text.split('');
    if (index < currentText.length) {
      currentText[index] = value;
    } else {
      currentText.add(value);
    }
    return currentText.join();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure controllers are initialized before building
    if (_controllers.isEmpty || _focusNodes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: widget.mainAxisAlignment,
      children: List.generate(widget.length, (index) {
        return Container(
          width: widget.pinTheme.fieldWidth,
          height: widget.pinTheme.fieldHeight,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            color: widget.enableActiveFill
                ? widget.pinTheme.activeColor.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: widget.pinTheme.borderRadius,
            border: Border.all(
              color: _controllers[index].text.isNotEmpty
                  ? widget.pinTheme.activeColor
                  : widget.pinTheme.inactiveColor,
              width: widget.pinTheme.borderWidth,
            ),
          ),
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            autofocus: widget.autoFocus && index == 0,
            keyboardType: widget.keyboardType,
            textAlign: TextAlign.center,
            cursorColor: widget.cursorColor,
            style: widget.textStyle,
            decoration: InputDecoration(
              border: InputBorder.none,
              counterText: '', // Remove the character counter
              hintText: widget.hintCharacter,
              hintStyle: TextStyle(color: widget.pinTheme.inactiveColor),
            ),
            maxLength: 1,
            onChanged: (value) => _onChanged(index, value),
          ),
        );
      }),
    );
  }
}

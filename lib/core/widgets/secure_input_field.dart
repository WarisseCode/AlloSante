import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

/// Champ de saisie sécurisé pour identifiants sensibles
/// (Email, Mot de passe, Code OTP, Numéro de téléphone)
class SecureInputField extends StatefulWidget {
  const SecureInputField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.initialValue,
    this.inputType = SecureInputType.text,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.maxLength,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.focusNode,
    this.errorText,
    this.helperText,
  });

  /// Label du champ
  final String label;
  
  /// Texte d'indication
  final String? hint;
  
  /// Controller
  final TextEditingController? controller;
  
  /// Valeur initiale
  final String? initialValue;
  
  /// Type d'entrée sécurisée
  final SecureInputType inputType;
  
  /// Validateur
  final String? Function(String?)? validator;
  
  /// Callback lors du changement
  final ValueChanged<String>? onChanged;
  
  /// Callback lors de la soumission
  final ValueChanged<String>? onSubmitted;
  
  /// Icône de préfixe
  final IconData? prefixIcon;
  
  /// Widget de suffixe personnalisé
  final Widget? suffixIcon;
  
  /// État d'activation
  final bool enabled;
  
  /// Lecture seule
  final bool readOnly;
  
  /// Longueur maximale
  final int? maxLength;
  
  /// Action du clavier
  final TextInputAction textInputAction;
  
  /// Hints pour le remplissage automatique
  final Iterable<String>? autofillHints;
  
  /// Focus node
  final FocusNode? focusNode;
  
  /// Texte d'erreur externe
  final String? errorText;
  
  /// Texte d'aide
  final String? helperText;

  @override
  State<SecureInputField> createState() => _SecureInputFieldState();
}

class _SecureInputFieldState extends State<SecureInputField> {
  late bool _obscureText;
  late TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.inputType == SecureInputType.password;
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  TextInputType get _keyboardType {
    switch (widget.inputType) {
      case SecureInputType.email:
        return TextInputType.emailAddress;
      case SecureInputType.phone:
        return TextInputType.phone;
      case SecureInputType.password:
      case SecureInputType.otp:
        return TextInputType.number;
      case SecureInputType.text:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter> get _inputFormatters {
    switch (widget.inputType) {
      case SecureInputType.phone:
        return [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(AppConstants.beninPhoneLength),
        ];
      case SecureInputType.otp:
        return [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(widget.maxLength ?? AppConstants.otpLength),
        ];
      default:
        return [];
    }
  }

  Iterable<String> get _autofillHints {
    if (widget.autofillHints != null) {
      return widget.autofillHints!;
    }
    switch (widget.inputType) {
      case SecureInputType.email:
        return [AutofillHints.email];
      case SecureInputType.password:
        return [AutofillHints.password];
      case SecureInputType.phone:
        return [AutofillHints.telephoneNumber];
      case SecureInputType.otp:
        return [AutofillHints.oneTimeCode];
      case SecureInputType.text:
        return [];
    }
  }

  IconData get _defaultPrefixIcon {
    switch (widget.inputType) {
      case SecureInputType.email:
        return Icons.email_outlined;
      case SecureInputType.password:
        return Icons.lock_outline;
      case SecureInputType.phone:
        return Icons.phone_outlined;
      case SecureInputType.otp:
        return Icons.security_outlined;
      case SecureInputType.text:
        return Icons.edit_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: hasError
                ? AppColors.error
                : _isFocused
                    ? AppColors.primary
                    : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        
        // Champ de texte
        Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              _isFocused = hasFocus;
            });
          },
          child: TextFormField(
            controller: _controller,
            focusNode: widget.focusNode,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            obscureText: _obscureText,
            keyboardType: _keyboardType,
            textInputAction: widget.textInputAction,
            inputFormatters: _inputFormatters,
            autofillHints: _autofillHints,
            maxLength: widget.maxLength,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            validator: widget.validator,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              counterText: '',
              errorText: widget.errorText,
              helperText: widget.helperText,
              helperStyle: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              prefixIcon: Icon(
                widget.prefixIcon ?? _defaultPrefixIcon,
                color: hasError
                    ? AppColors.error
                    : _isFocused
                        ? AppColors.primary
                        : AppColors.textSecondary,
              ),
              suffixIcon: widget.inputType == SecureInputType.password
                  ? IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : widget.suffixIcon,
              filled: true,
              fillColor: widget.enabled
                  ? AppColors.surface
                  : AppColors.backgroundGrey,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
                vertical: AppConstants.defaultPadding,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                borderSide: const BorderSide(color: AppColors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                borderSide: const BorderSide(color: AppColors.error, width: 2),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Types d'entrées sécurisées
enum SecureInputType {
  text,
  email,
  password,
  phone,
  otp,
}

/// Champ de numéro de téléphone béninois avec préfixe
class BeninPhoneField extends StatelessWidget {
  const BeninPhoneField({
    super.key,
    required this.controller,
    this.label = 'Numéro de téléphone',
    this.hint = 'Ex: 97 00 00 00',
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.errorText,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: errorText != null ? AppColors.error : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Préfixe pays
            Container(
              height: AppConstants.inputHeight,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey,
                border: Border.all(color: AppColors.border),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(AppConstants.borderRadius),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drapeau Bénin (simplifié)
                  Container(
                    width: 24,
                    height: 16,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          color: const Color(0xFF008751), // Vert Bénin
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  color: const Color(0xFFFCD116), // Jaune
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  color: const Color(0xFFE8112D), // Rouge
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '+229',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Champ de numéro
            Expanded(
              child: TextFormField(
                controller: controller,
                enabled: enabled,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(AppConstants.beninPhoneLength),
                  _PhoneNumberFormatter(),
                ],
                autofillHints: const [AutofillHints.telephoneNumber],
                onChanged: onChanged,
                validator: validator,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  letterSpacing: 1.5,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: AppColors.textHint,
                    letterSpacing: 0,
                  ),
                  errorText: errorText,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                    vertical: AppConstants.defaultPadding,
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(AppConstants.borderRadius),
                    ),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(AppConstants.borderRadius),
                    ),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(AppConstants.borderRadius),
                    ),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  errorBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(AppConstants.borderRadius),
                    ),
                    borderSide: BorderSide(color: AppColors.error),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Formatter pour espacer les numéros de téléphone (XX XX XX XX)
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 2 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

import 'package:elo_vital/src/controller/auth_controller.dart';
import 'package:elo_vital/src/screens/main_screen.dart';
import 'package:elo_vital/src/theme/app_colors.dart';
import 'package:elo_vital/src/utils/app_date_format.dart';
import 'package:elo_vital/src/utils/form_validators.dart';
import 'package:elo_vital/src/widgets/app_text_field_widget.dart';
import 'package:elo_vital/src/widgets/error_message_widget.dart';
import 'package:elo_vital/src/widgets/loading_button_widget.dart';
import 'package:elo_vital/src/widgets/password_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Cadastro do idoso: nome, e-mail, data de nascimento, senha e consentimento
/// para o uso dos dados de saúde.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final birthDateController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  DateTime? birthDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthController>().clearError();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    birthDateController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: birthDate ?? DateTime(now.year - 65),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Data de nascimento',
    );
    if (picked == null || !mounted) return;

    setState(() {
      birthDate = picked;
      birthDateController.text = AppDateFormat.shortDate(picked);
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!formKey.currentState!.validate()) return;

    final authController = context.read<AuthController>();
    final success = await authController.register(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
      birthDate: birthDate!,
    );
    if (!mounted || !success) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
      (route) => false,
    );
  }

  void _showPrivacyPolicy() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Política de privacidade'),
          content: const SingleChildScrollView(
            child: Text(
              'Texto provisório. Seus dados de saúde (remédios, medições e '
              'consultas) serão usados apenas para organizar a sua rotina e '
              'ficarão visíveis somente para você e para o cuidador que você '
              'autorizar. Você pode excluir a sua conta e os seus dados a '
              'qualquer momento.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Vamos começar',
                  style: textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Preencha os seus dados para criar a conta.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),
                AppTextFieldWidget(
                  controller: nameController,
                  label: 'Nome completo',
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  validator: FormValidators.name,
                ),
                const SizedBox(height: 20),
                AppTextFieldWidget(
                  controller: emailController,
                  label: 'E-mail',
                  hint: 'exemplo@email.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: FormValidators.email,
                ),
                const SizedBox(height: 20),
                AppTextFieldWidget(
                  controller: birthDateController,
                  label: 'Data de nascimento',
                  hint: 'Toque para escolher a data',
                  readOnly: true,
                  onTap: _pickBirthDate,
                  suffixIcon: const Icon(Icons.calendar_today_outlined),
                  validator: (value) => FormValidators.requiredField(
                    value,
                    'Escolha a sua data de nascimento.',
                  ),
                ),
                const SizedBox(height: 20),
                PasswordFieldWidget(
                  controller: passwordController,
                  label: 'Senha',
                  textInputAction: TextInputAction.next,
                  validator: FormValidators.newPassword,
                ),
                const SizedBox(height: 20),
                PasswordFieldWidget(
                  controller: confirmPasswordController,
                  label: 'Confirmar senha',
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value != passwordController.text) {
                      return 'As senhas não são iguais.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                FormField<bool>(
                  initialValue: false,
                  validator: (value) {
                    if (value == true) return null;
                    return 'Para criar a conta, aceite o uso dos seus dados de saúde.';
                  },
                  builder: (state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CheckboxListTile(
                          value: state.value ?? false,
                          onChanged: (value) => state.didChange(value),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'Li e aceito o uso dos meus dados de saúde',
                            style: textTheme.bodyLarge,
                          ),
                        ),
                        if (state.hasError)
                          Text(
                            state.errorText!,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                      ],
                    );
                  },
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: _showPrivacyPolicy,
                    child: const Text('Ler a política de privacidade'),
                  ),
                ),
                const SizedBox(height: 12),
                Consumer<AuthController>(
                  builder: (context, authController, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (authController.errorMessage != null) ...[
                          ErrorMessageWidget(
                            message: authController.errorMessage!,
                          ),
                          const SizedBox(height: 20),
                        ],
                        LoadingButtonWidget(
                          label: 'Criar conta',
                          isLoading: authController.isLoading,
                          onPressed: _submit,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

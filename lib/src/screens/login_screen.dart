import 'package:elo_vital/src/controller/auth_controller.dart';
import 'package:elo_vital/src/screens/main_screen.dart';
import 'package:elo_vital/src/screens/register_screen.dart';
import 'package:elo_vital/src/theme/app_colors.dart';
import 'package:elo_vital/src/utils/form_validators.dart';
import 'package:elo_vital/src/widgets/app_text_field_widget.dart';
import 'package:elo_vital/src/widgets/error_message_widget.dart';
import 'package:elo_vital/src/widgets/loading_button_widget.dart';
import 'package:elo_vital/src/widgets/password_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Entrada do idoso: e-mail e senha.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!formKey.currentState!.validate()) return;

    final authController = context.read<AuthController>();
    final success = await authController.login(
      email: emailController.text,
      password: passwordController.text,
    );
    if (!mounted || !success) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
      (route) => false,
    );
  }

  void _showForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('A recuperação de senha estará disponível em breve.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Image.asset(
                    'assets/images/elo_vital_symbol.png',
                    height: 120,
                    semanticLabel: 'Logo do Elo Vital',
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Bem-vindo de volta',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Entre para ver a sua rotina de hoje.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
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
                PasswordFieldWidget(
                  controller: passwordController,
                  label: 'Senha',
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: (value) => FormValidators.requiredField(
                    value,
                    'Digite a sua senha.',
                  ),
                ),
                const SizedBox(height: 24),
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
                          label: 'Entrar',
                          isLoading: authController.isLoading,
                          onPressed: _submit,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _showForgotPassword,
                  child: const Text('Esqueci minha senha'),
                ),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('Ainda não tem conta?', style: textTheme.bodyLarge),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text('Criar conta'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

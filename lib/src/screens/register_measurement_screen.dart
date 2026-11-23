import 'package:elo_vital/src/controller/auth_controller.dart';
import 'package:elo_vital/src/controller/measurement_controller.dart';
import 'package:elo_vital/src/controller/routine_controller.dart';
import 'package:elo_vital/src/enums/glucose_moment_enum.dart';
import 'package:elo_vital/src/enums/measurement_type_enum.dart';
import 'package:elo_vital/src/enums/routine_status_enum.dart';
import 'package:elo_vital/src/models/measurement_model.dart';
import 'package:elo_vital/src/models/routine_item_model.dart';
import 'package:elo_vital/src/theme/app_colors.dart';
import 'package:elo_vital/src/utils/form_validators.dart';
import 'package:elo_vital/src/widgets/app_text_field_widget.dart';
import 'package:elo_vital/src/widgets/error_message_widget.dart';
import 'package:elo_vital/src/widgets/loading_button_widget.dart';
import 'package:elo_vital/src/widgets/measurement_result_widget.dart';
import 'package:elo_vital/src/widgets/measurement_tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

/// Registro de pressão arterial ou glicemia, com o resultado "Normal" ou
/// "Atenção". Se veio de uma tarefa da rotina, ela é marcada como feita.
class RegisterMeasurementScreen extends StatefulWidget {
  const RegisterMeasurementScreen({
    super.key,
    this.initialType = MeasurementTypeEnum.bloodPressure,
    this.routineItem,
  });

  final MeasurementTypeEnum initialType;
  final RoutineItemModel? routineItem;

  @override
  State<RegisterMeasurementScreen> createState() =>
      _RegisterMeasurementScreenState();
}

class _RegisterMeasurementScreenState extends State<RegisterMeasurementScreen> {
  static final List<TextInputFormatter> _numberFormatters = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(3),
  ];

  final formKey = GlobalKey<FormState>();
  final systolicController = TextEditingController();
  final diastolicController = TextEditingController();
  final glucoseController = TextEditingController();

  late MeasurementTypeEnum selectedType;
  GlucoseMomentEnum selectedMoment = GlucoseMomentEnum.fasting;
  MeasurementModel? savedMeasurement;

  @override
  void initState() {
    super.initState();
    selectedType = widget.initialType;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRecent());
  }

  @override
  void dispose() {
    systolicController.dispose();
    diastolicController.dispose();
    glucoseController.dispose();
    super.dispose();
  }

  Future<void> _loadRecent() async {
    if (!mounted) return;

    final userId = context.read<AuthController>().currentUser?.id;
    if (userId == null) return;

    final measurementController = context.read<MeasurementController>();
    measurementController.clearError();
    await measurementController.loadRecent(userId);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!formKey.currentState!.validate()) return;

    final userId = context.read<AuthController>().currentUser?.id;
    if (userId == null) return;

    final measurementController = context.read<MeasurementController>();
    final routineController = context.read<RoutineController>();

    final MeasurementModel? saved;
    if (selectedType == MeasurementTypeEnum.bloodPressure) {
      saved = await measurementController.saveBloodPressure(
        userId: userId,
        systolic: int.parse(systolicController.text.trim()),
        diastolic: int.parse(diastolicController.text.trim()),
      );
    } else {
      saved = await measurementController.saveGlucose(
        userId: userId,
        value: int.parse(glucoseController.text.trim()),
        moment: selectedMoment,
      );
    }
    if (saved == null) return;

    final routineItem = widget.routineItem;
    if (routineItem != null) {
      await routineController.setStatus(routineItem, RoutineStatusEnum.done);
    }
    if (!mounted) return;

    setState(() => savedMeasurement = saved);
  }

  void _registerAnother() {
    systolicController.clear();
    diastolicController.clear();
    glucoseController.clear();
    setState(() => savedMeasurement = null);
  }

  @override
  Widget build(BuildContext context) {
    final measurement = savedMeasurement;

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar medição')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: measurement == null
              ? _buildForm(context)
              : MeasurementResultWidget(
                  measurement: measurement,
                  onDone: () => Navigator.pop(context),
                  onRegisterAnother: _registerAnother,
                ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<MeasurementTypeEnum>(
            segments: [
              for (final type in MeasurementTypeEnum.values)
                ButtonSegment(
                  value: type,
                  label: Text(type.shortLabel),
                  icon: Icon(type.icon),
                ),
            ],
            selected: {selectedType},
            onSelectionChanged: (selection) {
              setState(() => selectedType = selection.first);
            },
            style: SegmentedButton.styleFrom(
              minimumSize: const Size(0, 56),
              textStyle: textTheme.labelLarge,
              foregroundColor: AppColors.textSecondary,
              selectedForegroundColor: AppColors.primary,
              selectedBackgroundColor: AppColors.surfaceSoft,
            ),
          ),
          const SizedBox(height: 24),
          if (selectedType == MeasurementTypeEnum.bloodPressure)
            _buildBloodPressureFields(textTheme)
          else
            _buildGlucoseFields(textTheme),
          const SizedBox(height: 24),
          Consumer<MeasurementController>(
            builder: (context, measurementController, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (measurementController.errorMessage != null) ...[
                    ErrorMessageWidget(
                      message: measurementController.errorMessage!,
                    ),
                    const SizedBox(height: 20),
                  ],
                  LoadingButtonWidget(
                    label: 'Salvar medição',
                    isLoading: measurementController.isSaving,
                    onPressed: _submit,
                  ),
                  if (measurementController.recentMeasurements.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    Text('Últimas medições', style: textTheme.titleLarge),
                    const SizedBox(height: 12),
                    for (final recent in measurementController.recentMeasurements)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: MeasurementTileWidget(measurement: recent),
                      ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBloodPressureFields(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextFieldWidget(
                controller: systolicController,
                label: 'Máxima',
                suffixText: 'mmHg',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: _numberFormatters,
                textStyle: textTheme.headlineMedium,
                validator: (value) => FormValidators.integerInRange(
                  value,
                  emptyMessage: 'Digite a máxima.',
                  min: 50,
                  max: 260,
                  rangeMessage: 'Confira o valor (de 50 a 260).',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppTextFieldWidget(
                controller: diastolicController,
                label: 'Mínima',
                suffixText: 'mmHg',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: _numberFormatters,
                textStyle: textTheme.headlineMedium,
                validator: (value) {
                  final error = FormValidators.integerInRange(
                    value,
                    emptyMessage: 'Digite a mínima.',
                    min: 30,
                    max: 160,
                    rangeMessage: 'Confira o valor (de 30 a 160).',
                  );
                  if (error != null) return error;

                  final systolic = int.tryParse(systolicController.text.trim());
                  if (systolic != null && int.parse(value!.trim()) >= systolic) {
                    return 'A mínima precisa ser menor que a máxima.';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'A máxima é o número maior (ex.: 120). A mínima é o número menor (ex.: 80).',
          style: textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildGlucoseFields(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextFieldWidget(
          controller: glucoseController,
          label: 'Glicemia',
          suffixText: 'mg/dL',
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          inputFormatters: _numberFormatters,
          textStyle: textTheme.headlineMedium,
          validator: (value) => FormValidators.integerInRange(
            value,
            emptyMessage: 'Digite o valor da glicemia.',
            min: 20,
            max: 600,
            rangeMessage: 'Confira o valor (de 20 a 600).',
          ),
        ),
        const SizedBox(height: 20),
        Text('Quando você mediu?', style: textTheme.titleSmall),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final moment in GlucoseMomentEnum.values)
              ChoiceChip(
                label: Text(moment.label),
                selected: selectedMoment == moment,
                showCheckmark: true,
                onSelected: (_) => setState(() => selectedMoment = moment),
                labelStyle: textTheme.labelLarge?.copyWith(
                  color: AppColors.textPrimary,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                selectedColor: AppColors.surfaceSoft,
                backgroundColor: AppColors.surface,
                side: BorderSide(
                  color: selectedMoment == moment
                      ? AppColors.primary
                      : AppColors.border,
                  width: 2,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

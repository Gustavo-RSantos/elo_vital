/// Momento em que a glicemia foi medida (muda a faixa de referência).
enum GlucoseMomentEnum {
  fasting(label: 'Em jejum'),
  beforeMeal(label: 'Antes da refeição'),
  afterMeal(label: 'Depois da refeição');

  final String label;

  const GlucoseMomentEnum({required this.label});
}

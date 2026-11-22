/// Para onde o app vai depois da Splash.
enum StartDestinationEnum {
  /// Primeira vez no app: mostra a apresentação.
  onboarding,

  /// Já viu a apresentação, mas não tem sessão ativa.
  login,

  /// Sessão ativa: vai direto para a tela principal.
  main,
}

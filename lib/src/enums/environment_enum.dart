/// Variáveis de ambiente lidas em tempo de compilação com --dart-define.
///
/// Por padrão o app usa dados locais (SQLite). Para usar a API:
/// flutter run --dart-define=USE_LOCAL_DATA=false
///             --dart-define=API_BASE_URL=http://10.0.2.2:8080
enum EnvironmentEnum {
  apiBaseUrl(
    String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8080'),
  ),
  useLocalData(String.fromEnvironment('USE_LOCAL_DATA', defaultValue: 'true'));

  final String value;

  const EnvironmentEnum(this.value);
}

## 导出 schema
function export_schemas() {
  mkdir drift_schemas
  flutter pub run build_runner build && flutter pub get
  flutter pub run drift_dev schema dump lib/service/drift/database.dart drift_schemas/
}

function step_migration() {
  ## 处理迁移
  flutter pub run drift_dev schema steps drift_schemas/ lib/service/drift/schema_versions.dart
}

function test_migration() {
  flutter pub run drift_dev schema generate drift_schemas/ test/generated_migrations/
}

export_schemas
step_migration
#test_migration
# Naming Conventions

- Controllers: `<feature>_controller.dart` → `class <Feature>Controller extends _$<Feature>Controller`
- States: `<feature>_state.dart` → `@freezed class <Feature>State`
- Repositories: `<feature>_repository.dart` → interface + `<Feature>RepositoryImpl`
- Services: `<feature>_service.dart` → `class <Feature>Service`
- Mappers: `<feature>_mapper.dart` → extension on DTO or standalone class
- Screens: `<feature>_screen.dart` → `class <Feature>Screen extends ConsumerWidget`

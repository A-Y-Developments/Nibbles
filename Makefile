.PHONY: gen gen-watch run-dev run-prod run-qa build-qa-sim clean fix

gen:
	dart run build_runner build --delete-conflicting-outputs

gen-watch:
	dart run build_runner watch --delete-conflicting-outputs

run-dev:
	flutter run -t lib/main_dev.dart --flavor dev

run-prod:
	flutter run -t lib/main.dart --flavor prod

# QA bypass — boots straight into /home with synthetic auth/baby. Used by the
# visual-gate render phase in the build pipeline.
run-qa:
	flutter run -t lib/main_dev.dart --flavor dev --dart-define=NIBBLES_QA_BYPASS=true

build-qa-sim:
	flutter build ios --simulator --debug -t lib/main_dev.dart --no-codesign --dart-define=NIBBLES_QA_BYPASS=true

clean:
	flutter clean && flutter pub get

fix:
	dart fix --apply && dart format .

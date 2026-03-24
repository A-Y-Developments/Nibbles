.PHONY: gen gen-watch run-dev run-prod clean fix

gen:
	dart run build_runner build --delete-conflicting-outputs

gen-watch:
	dart run build_runner watch --delete-conflicting-outputs

run-dev:
	flutter run -t lib/main_dev.dart --flavor dev

run-prod:
	flutter run -t lib/main.dart --flavor prod

clean:
	flutter clean && flutter pub get

fix:
	dart fix --apply && dart format .

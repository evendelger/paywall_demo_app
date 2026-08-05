# ==== CONFIGURATION ====

# Настройки для генерации Keystore
KEY_STORE_PASS ?= _
KEY_ALIAS_PASS ?= _
KEY_ALIAS ?= upload
KEYSTORE_PATH ?= keystore.jks
KEY_PROPERTIES_PATH ?= android/key.properties

# ==== НОВЫЙ ПРОЕКТ ИЗ ШАБЛОНА ====

# Пример:
#   make rename NAME=my_app BUNDLE_ID=com.company.myapp APP_NAME="My App" DOMAIN=myapp.com
DOMAIN ?= example.com

.PHONY: rename
rename:
	@if [ -z "$(NAME)" ] || [ -z "$(BUNDLE_ID)" ] || [ -z "$(APP_NAME)" ]; then \
		echo "Использование: make rename NAME=my_app BUNDLE_ID=com.company.myapp APP_NAME=\"My App\" [DOMAIN=myapp.com]"; \
		exit 1; \
	fi
	dart run tool/rename.dart --name $(NAME) --bundle-id $(BUNDLE_ID) --app-name "$(APP_NAME)" --domain $(DOMAIN)
	flutter pub get
	flutter gen-l10n
	dart run build_runner build -d

# ==== DEVELOPMENT ====

.PHONY: run
run:
	flutter run --flavor development --dart-define-from-file=config/development.json

# ==== PRODUCTION ====

.PHONY: run-release
run-release:
	flutter run --flavor production --dart-define-from-file=config/production.json --release

.PHONY: build-apk
build-apk:
	flutter build apk --flavor production --dart-define-from-file=config/production.json --release

.PHONY: build-android
build-android:
	flutter build appbundle --target-platform android-arm,android-arm64,android-x64 --flavor production --dart-define-from-file=config/production.json

.PHONY: build-ios
build-ios:
	flutter build ipa --flavor production --dart-define-from-file=config/production.json

# ==== SHOREBIRD RELEASE ====

.PHONY: shorebird-ios
shorebird-ios:
	shorebird release ios --flutter-version 3.44.1 --flavor production -- --dart-define-from-file=config/production.json

.PHONY: shorebird-android
shorebird-android:
	shorebird release android --flutter-version 3.44.1 --flavor production -- --dart-define-from-file=config/production.json

# ==== ANDROID SETUP ====

.PHONY: generate-keystore
generate-keystore:
	@echo "Generating keystore at $(KEYSTORE_PATH)..."
	@if [ -f $(KEYSTORE_PATH) ]; then \
		echo "⚠️  Keystore already exists! Skipping generation to prevent overwrite."; \
	else \
		keytool -genkey -v -keystore android/app/$(KEYSTORE_PATH) \
		-keyalg RSA -keysize 2048 -validity 10000 \
		-alias $(KEY_ALIAS) -storepass $(KEY_STORE_PASS) -keypass $(KEY_ALIAS_PASS) \
		-dname "CN=Android Release,O=Example,C=RU"; \
		echo "✅ Keystore created."; \
	fi

.PHONY: generate-key-properties
generate-key-properties:
	@echo "Generating $(KEY_PROPERTIES_PATH)..."
	@echo "storePassword=$(KEY_STORE_PASS)" > $(KEY_PROPERTIES_PATH)
	@echo "keyPassword=$(KEY_ALIAS_PASS)" >> $(KEY_PROPERTIES_PATH)
	@echo "keyAlias=$(KEY_ALIAS)" >> $(KEY_PROPERTIES_PATH)
	@echo "storeFile=$(KEYSTORE_PATH)" >> $(KEY_PROPERTIES_PATH)
	@echo "✅ key.properties created."

.PHONY: setup-android
setup-android: generate-keystore generate-key-properties

# ==== COMMON UTILS ====

.PHONY: clean
clean:
	flutter clean
	rm -rf ios/Pods ios/Podfile.lock pubspec.lock
	flutter pub get
	cd ios && pod install --repo-update && cd ..

.PHONY: runner
runner:
	dart run build_runner build -d

.PHONY: watch-runner
watch-runner:
	dart run build_runner watch -d

.PHONY: splash
splash:
	dart run flutter_native_splash:create

.PHONY: splash-remove
splash-remove:
	dart run flutter_native_splash:remove

.PHONY: fix
fix:
	dart fix --apply


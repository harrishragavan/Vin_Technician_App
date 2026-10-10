import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing comes from android/key.properties (never committed; see .gitignore)
// or from CI environment variables (KEYSTORE_PATH, KEYSTORE_PASSWORD, KEY_ALIAS, KEY_PASSWORD),
// which GitHub Actions populates from repository secrets.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val hasKeystoreFile = keystorePropertiesFile.exists()
if (hasKeystoreFile) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
val envKeystorePath = System.getenv("KEYSTORE_PATH")
val hasReleaseSigning = hasKeystoreFile || envKeystorePath != null

android {
    namespace = "com.vintrosys.vin_technician_app"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.vintrosys.vin_technician_app"
        // Covers almost every phone in use; meets the current Play target rule.
        minSdk = 26
        targetSdk = 36
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Never committed: set via the MAPS_API_KEY GitHub Actions secret in CI,
        // or a local-only android/local.properties entry for a dev build.
        manifestPlaceholders["MAPS_API_KEY"] =
            System.getenv("MAPS_API_KEY")
                ?: project.findProperty("MAPS_API_KEY") as String?
                ?: ""
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(
                    keystoreProperties.getProperty("storeFile") ?: envKeystorePath ?: ""
                )
                storePassword = keystoreProperties.getProperty("storePassword")
                    ?: System.getenv("KEYSTORE_PASSWORD")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                    ?: System.getenv("KEY_ALIAS")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                    ?: System.getenv("KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            // Falls back to the debug key so `flutter run --release` and early CI
            // builds work before the signing secrets are configured; real release
            // artifacts for the Play track require the "release" signing config above.
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }

    splits {
        abi {
            isEnable = true
            reset()
            include("armeabi-v7a", "arm64-v8a", "x86_64")
            isUniversalApk = true
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

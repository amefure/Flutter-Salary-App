plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val secretPropertiesFile = rootProject.file("secret.properties")
val secretProperties = java.util.Properties()
secretProperties.load(secretPropertiesFile.inputStream())

android {
    namespace = "com.ame.Salary"
    compileSdk = flutter.compileSdkVersion
    // flutter.ndkVersionを使用しない
    // 上記はflutterSDK自体に依存しているNDKバージョンのため
    ndkVersion = "28.0.13004108"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.ame.Salary"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        debug {
            // テスト用
            manifestPlaceholders["admobAppId"] = "ca-app-pub-3940256099942544~3347511713"
        }
        release {
            // 本番用
            manifestPlaceholders["admobAppId"] = secretProperties["ADMOB_APP_ID"] as String
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            // signingConfig = signingConfigs.getByName("debug")
            signingConfig signingConfigs.release
        }
    }
}

flutter {
    source = "../.."
}

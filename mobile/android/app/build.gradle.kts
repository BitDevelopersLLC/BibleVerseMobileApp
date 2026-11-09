import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release-signing credentials live in android/key.properties, which is gitignored and never
// committed. Debug builds and `flutter run --release` work without it. A fork or a fresh clone
// can create its own upload key; see https://docs.flutter.dev/deployment/android#sign-the-app.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

android {
    namespace = "app.withoutprice"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "app.withoutprice"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Both come from `version:` in pubspec.yaml (name+code, e.g. 1.0.0+1).
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    // A Google Play bundle must never be signed with the debug key, so building one without
    // key.properties fails loudly instead of quietly falling back.
    val buildingStoreBundle = gradle.startParameter.taskNames.any { it.contains("bundleRelease", ignoreCase = true) }
    if (buildingStoreBundle && !keystorePropertiesFile.exists()) {
        throw GradleException(
            "android/key.properties is missing, so this bundle would be signed with the debug key. " +
                "Add key.properties (upload keystore) before building for Google Play."
        )
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Runs the lock screen refresh in the background (daily or hourly, see VerseCadence).
    implementation("androidx.work:work-runtime-ktx:2.10.1")

    // Local unit tests only (src/test). Not part of the app.
    testImplementation("junit:junit:4.13.2")
}

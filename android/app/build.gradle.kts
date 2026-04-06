plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.finance_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // 🛠️ FIX: Added '=' and 'is' prefix for Boolean
        isCoreLibraryDesugaringEnabled = true
        
        // 🛠️ FIX: Added '=' for assignments
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        // 🛠️ FIX: Used double quotes "" instead of single quotes ''
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.finance_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // 🛠️ FIX: Added '=' for assignment
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // 🛠️ FIX: Used parentheses () and double quotes ""
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
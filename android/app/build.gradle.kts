plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

android {
    namespace = "com.aydev.nibbles"
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
        applicationId = "com.aydev.nibbles"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "environment"

    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "Nibbles Dev")
        }
        create("prod") {
            dimension = "environment"
            resValue("string", "app_name", "Nibbles")
        }
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

// Copy the per-flavor google-services.json into the app root before the
// google-services plugin processes it. The real files are git-ignored;
// place them at android/app/src/<flavor>/google-services.json after running
// `flutterfire configure --project nibbles-<flavor>`.
android.applicationVariants.all {
    val flavor = flavorName
    val googleServicesSource = file("src/$flavor/google-services.json")
    if (googleServicesSource.exists()) {
        copy {
            from(googleServicesSource)
            into(".")
        }
    }
}

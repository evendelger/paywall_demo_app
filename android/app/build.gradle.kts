import java.util.Properties
import java.io.FileInputStream
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.test.paywalldemo"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    defaultConfig {
        applicationId = "com.test.paywalldemo"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
    if (keystorePropertiesFile.exists()) {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"]?.toString() ?: ""
            keyPassword = keystoreProperties["keyPassword"]?.toString() ?: ""
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"]?.toString() ?: ""
        }
    }
}

   buildTypes {
    release {
        if (keystorePropertiesFile.exists()) {
            signingConfig = signingConfigs.getByName("release")
        } else {
            println("⚠️ key.properties not found — release build will not be signed.")
        }
    }
}
    flavorDimensions += "default"

    productFlavors {
        create("development") {
            dimension = "default"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            manifestPlaceholders["appName"] = "Paywall Demo (dev)"
        }
        create("production") {
            dimension = "default"
            manifestPlaceholders["appName"] = "Paywall Demo"
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = JvmTarget.JVM_21
    }
}

flutter {
    source = "../.."
}
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

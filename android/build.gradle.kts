// Dosya Yolu: android/build.gradle

buildscript {
    ext.kotlin_version = '1.8.21' // Bu satır sizde farklı bir versiyon olabilir.
    
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // Mevcut Android Gradle Plugin (Sizdeki versiyon farklı olabilir)
        classpath 'com.android.tools.build:gradle:7.3.0' 
        
        // Flutter Gradle Plugin
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        
        // ******************************************************
        // BURAYA EKLENECEK KISIM: Firebase Google Services Eklentisi
        classpath 'com.google.gms:google-services:4.4.0' // En son stabil versiyonu kullanın
        // ******************************************************
    }
}


allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
buildscript {
    val kotlinVersion = "1.8.22" // Define Kotlin version
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.3.0") // Android Gradle Plugin
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion") // Kotlin Plugin
    }
}

plugins {
    id("com.android.application") version "8.3.0" apply false
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

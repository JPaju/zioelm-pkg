Global / onChangedBuildSource := ReloadOnSourceChanges

Global / excludeLintKeys ++= Set(
  autoStartServer,
  turbo,
  evictionWarningOptions,
)

ThisBuild / autoStartServer        := false
ThisBuild / includePluginResolvers := true
ThisBuild / turbo                  := true

ThisBuild / watchBeforeCommand           := Watch.clearScreen
ThisBuild / watchTriggeredMessage        := Watch.clearScreenOnTrigger
ThisBuild / watchForceTriggerOnAnyChange := true

ThisBuild / scalacOptions ++=
  Seq(
    "-deprecation",
    "-feature",
    "-language:implicitConversions",
    "-unchecked",
    "-Xfatal-warnings",
    "-Yexplicit-nulls",
    "-Ysafe-init",
    "-Ykind-projector",
    "-Wconf:id=E029:error,msg=non-initialized:error,msg=spezialized:error,cat=unchecked:error", // Pattern match exhaustivity etc.
  ) ++ Seq("-source", "future")

val scala3Version = "3.1.0"

lazy val root = project
  .in(file("."))
  .settings(
    name         := "zio-pkg",
    version      := "0.1.0-SNAPSHOT",
    scalaVersion := scala3Version,
    libraryDependencies ++= Seq(
      "dev.zio" %% "zio-test"    % "1.0.13",
      "dev.zio" %% "zio-streams" % "1.0.13",
      "dev.zio" %% "zio-json"    % "0.2.0-M3",
      "io.d11"  %% "zhttp"       % "1.0.0.0-RC22",
    ),
  )

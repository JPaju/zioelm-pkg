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
    libraryDependencies ++= (zioDependencies ++ sttpDependencies),
  )

lazy val zioDependencies = Seq(
  "dev.zio" %% "zio"         % "1.0.13",
  "dev.zio" %% "zio-streams" % "1.0.13",
)

lazy val sttpDependencies = Seq(
  "com.softwaremill.sttp.tapir" %% "tapir-core"              % "0.20.0-M7",
  "com.softwaremill.sttp.tapir" %% "tapir-json-zio"          % "0.20.0-M7",
  "com.softwaremill.sttp.tapir" %% "tapir-zio-http-server"   % "0.20.0-M7",
  "com.softwaremill.sttp.tapir" %% "tapir-swagger-ui-bundle" % "0.20.0-M7",
)

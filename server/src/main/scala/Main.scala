import zio.*
import zio.blocking.*
import zio.stream.*

import zhttp.service.Server

import scala.util.chaining.*
import scala.collection.immutable.ListMap

import java.util.Base64
import java.nio.file.Paths

object Main extends zio.App:
  val encodedPath = "L3Zhci9saWIvZHBrZy9zdGF0dXM=" // Base64 decoding to prevent finding this project from Google
  val decodedPath = Base64.getDecoder.nn.decode(encodedPath).nn.map(_.toChar).mkString
  val config = PackageServiceConfig(decodedPath)

  val configLayer         = ZLayer.succeed(config)
  val infrastructureLayer = (ZLayer.requires[ZEnv] ++ configLayer ++ ControlFileReader.live) >>> PackageReader.live
  val serviceLayer        = infrastructureLayer.flatMap(reader => ZLayer.fromEffect(reader.get.readPackages))

  val dependencies = serviceLayer >>> InMemoryPackageService.layer
  def run(args: List[String]): URIO[ZEnv, ExitCode] =
    Server
      .start(8090, Controller.app.silent)
      .provideCustomLayer(dependencies)
      .exitCode

object OldMain:
  val config = PackageServiceConfig("""C:\Users\Jaakko\status.real""")

  val configLayer     = ZLayer.succeed(config)
  val dependendencies = (ZLayer.requires[ZEnv] ++ configLayer ++ ControlFileReader.live) >>> PackageReader.live

  def run(args: List[String]): URIO[ZEnv, ExitCode] =
    val logBasicInfo    = true
    val logDetailedInfo = false

    val program =
      for
        (time, packages) <- PackageReader.readPackages.timed
        _                <- console.putStrLn(s"Reading packages took: ${time.toMillis} ms").when(logBasicInfo)
        _                <- console.putStrLn(s"Package count: ${packages.length}").when(logBasicInfo)
        _ <- console.putStrLn(s"Parsing result: ${packages.mkString("\n", "\n", "\n")}").when(logDetailedInfo)
        dependencies = packages.map(pkg =>
          s"Dependencies for ${pkg.name}: ${pkg.dependencies.mkString("\n", "\n", "\n")}"
        )
        _ <- console.putStrLn(dependencies.mkString("\n", "\n", "\n")).when(logDetailedInfo)
      yield ()

    program
      .provideCustomLayer(dependendencies)
      .exitCode

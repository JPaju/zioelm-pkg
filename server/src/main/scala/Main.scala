import zio.*
import zio.blocking.*
import zio.stream.*

import zhttp.service.Server

import java.util.Base64

case class Config(packagesPath: String)

object Main extends zio.App:
  val encodedPath = "L3Zhci9saWIvZHBrZy9zdGF0dXM=" // Base64 decoding to prevent finding this project from Google
  val decodedPath = Base64.getDecoder.nn.decode(encodedPath).nn.map(_.toChar).mkString

  val config = Config(decodedPath)

  // Build dependency graph
  val configLayer         = ZLayer.succeed(config)
  val baseLayer           = ZLayer.requires[ZEnv] ++ configLayer
  val infrastructureLayer = (baseLayer ++ ControlFileReader.live) >>> PackageReader.live
  val serviceLayer        = infrastructureLayer.flatMap(reader => ZLayer.fromEffect(reader.get.readPackages))
  val appDependencies     = serviceLayer >>> InMemoryPackageService.layer

  def run(args: List[String]): URIO[ZEnv, ExitCode] =
    Server
      .start(8080, Controller.httpApp.silent)
      .provideCustomLayer(appDependencies)
      .exitCode

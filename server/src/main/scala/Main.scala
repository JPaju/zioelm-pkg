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

  val config = Config(decodedPath)

  val configLayer         = ZLayer.succeed(config)
  val baseLayer           = ZLayer.requires[ZEnv] ++ configLayer
  val infrastructureLayer = (baseLayer ++ ControlFileReader.live) >>> PackageReader.live
  val serviceLayer        = infrastructureLayer.flatMap(reader => ZLayer.fromEffect(reader.get.readPackages))

  val dependencies = serviceLayer >>> InMemoryPackageService.layer

  def run(args: List[String]): URIO[ZEnv, ExitCode] =
    Server
      .start(8080, Controller.httpApp.silent)
      .provideCustomLayer(dependencies)
      .exitCode

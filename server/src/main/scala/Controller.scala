import sttp.model.StatusCode
import sttp.tapir.ztapir.*
import sttp.tapir.server.ziohttp.*

import zio.*
import zio.json.*
import zhttp.http.*
import zhttp.http.middleware.Cors.CorsConfig

object Endpoint:
  import scala.language.unsafeNulls

  import sttp.tapir.Schema
  import sttp.tapir.json.zio.jsonBody
  import sttp.tapir.swagger.bundle.SwaggerInterpreter

  implicit private def packageSchema: Schema[PackageDTO]               = Schema.derived
  implicit private def dependencySchema: Schema[DependencyDTO]         = Schema.derived
  implicit private def packageDetailsSchema: Schema[PackageDetailsDTO] = Schema.derived

  val getPackages =
    endpoint
      .get
      .in("packages")
      .out(jsonBody[Seq[PackageDTO]])

  val getPackageDetails =
    endpoint
      .get
      .in("packages" / path[String]("packageId"))
      .errorOut(statusCode(StatusCode.NotFound))
      .out(jsonBody[PackageDetailsDTO])

  val swagger = // Path: /docs/index.html
    SwaggerInterpreter()
      .fromEndpoints[Task](List(getPackages, getPackageDetails), "ZIO Elm package", "0.1")

object Controller:
  private val packageListingRoute =
    Endpoint.getPackages.zServerLogic[Has[PackageService]](_ => ServerLogic.packageListing)

  private val packageDetailsRoute =
    Endpoint.getPackageDetails.zServerLogic[Has[PackageService]](ServerLogic.findPackageById)

  private val appRoutes = List(
    packageListingRoute,
    packageDetailsRoute,
  )

  val allowEverything = CorsConfig(anyOrigin = true, anyMethod = true)

  val httpApp =
    ZioHttpInterpreter().toHttp(appRoutes) @@ Middleware.cors(allowEverything) ++
      ZioHttpInterpreter().toHttp(Endpoint.swagger)

object ServerLogic:
  val packageListing =
    PackageService.getPackages.map { pkgs =>
      pkgs.map(PackageDTO.fromPackage)
    }

  def findPackageById(id: String) =
    PackageService
      .getPackageByName(id)
      .map(PackageDetailsDTO.fromPackage)

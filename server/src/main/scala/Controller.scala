import zio.*
import zio.json.*
import zhttp.http.*

object Controller:
  val allowEverything = CORSConfig(anyOrigin = true, anyMethod = true)

  val httpApp: HttpApp[Has[PackageService], Nothing] = Http.collectZIO[Request] {
    case Method.GET -> !! / "packages"      => packageListing
    case Method.GET -> !! / "packages" / id => findPackageById(id)
  } @@ Middleware.cors(allowEverything)

  private def packageListing =
    PackageService.getPackages.map { pkgs =>
      val dtos = pkgs.map(PackageDTO.fromPackage)
      Response.json(dtos.toJson)
    }

  private def findPackageById(id: String) =
    PackageService
      .getPackageByName(id)
      .fold(
        err => Response.status(Status.NOT_FOUND),
        pkg => Response.json(PackageDetailsDTO.fromPackage(pkg).toJson),
      )

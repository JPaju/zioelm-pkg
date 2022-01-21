import zio.*
import zio.json.*
import zhttp.http.*

object Controller:
  val httpApp: HttpApp[Has[PackageService], Nothing] = Http.collectZIO[Request] {
    case Method.GET -> !! / "packages" =>
      PackageService.getPackages.map { pkgs =>
        val dtos = pkgs.map(ConsicePackageDTO.fromPackage)
        Response.json(dtos.toJson)
      }
    case Method.GET -> !! / "packages" / name =>
      PackageService
        .getPackageByName(name)
        .fold(
          err => Response.status(Status.NOT_FOUND),
          pkg => Response.json(PackageDTO.fromPackage(pkg).toJson),
        )
  }

import zio.*

trait PackageService:
  def getPackages: UIO[Seq[Package]]
  def getPackageByName(name: String): IO[Unit, Package]

object PackageService:
  def getPackages: URIO[Has[PackageService], Seq[Package]] =
    ZIO.serviceWith(_.getPackages)

  def getPackageByName(name: String): ZIO[Has[PackageService], Unit, Package] =
    ZIO.serviceWith(_.getPackageByName(name))

class InMemoryPackageService(packages: Seq[Package]) extends PackageService:
  def getPackages: UIO[Seq[Package]] =
    UIO.succeed(packages)

  def getPackageByName(name: String): IO[Unit, Package] =
    ZIO
      .fromOption(packages.find(_.name == name))
      .mapError(_ => ())

object InMemoryPackageService:
  val layer = (InMemoryPackageService(_)).toLayer[PackageService]

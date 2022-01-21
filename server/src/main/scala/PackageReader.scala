import zio.*
import zio.stream.*
import zio.blocking.*
import java.nio.file.{ Paths, Path }

trait PackageReader:
  def readPackages: UIO[Seq[Package]]

object PackageReader:
  def readPackages: URIO[Has[PackageReader], Seq[Package]] =
    ZIO.serviceWith[PackageReader](_.readPackages)

  val live = (LivePackageReader(_, _)).toLayer[PackageReader]

class LivePackageReader(config: Config, reader: ControlFileReader) extends PackageReader:
  def readPackages: UIO[Seq[Package]] =
    ZIO
      .effect(Paths.get(config.packagesPath).nn)
      .flatMap(readPackageEntries)
      .map(addReverseDependencies)
      .orDieWith(new RuntimeException(s"Cannot read packages", _))

  private def readPackageEntries(path: Path): IO[Throwable, Seq[PackageEntry]] =
    reader
      .readFile(path)
      .map(PackageParser.fromControlfileParagraph)
      .collectRight // TODO Log errors if some packages could not be parsed
      .runCollect

  private def addReverseDependencies(packages: Seq[PackageEntry]): Seq[Package] =
    packages.map(_.toPackage(Set.empty)) // TODO

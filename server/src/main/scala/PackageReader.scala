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
      .map(entriesToPackages)
      .orDieWith(new RuntimeException(s"Cannot read packages", _))

  private def readPackageEntries(path: Path): IO[Throwable, Seq[PackageEntry]] =
    reader
      .readFile(path)
      .map(PackageParser.fromControlfileParagraph)
      .collectRight // TODO Log errors if some packages could not be parsed
      .runCollect

  private def entriesToPackages(packageEntries: Seq[PackageEntry]): Seq[Package] =
    lazy val packagesByName: Map[String, PackageEntry] = packageEntries.map(pkg => (pkg.name -> pkg)).toMap
    lazy val reverseDependencyGraph                    = resolveReverseDependencies(packageEntries)

    def resolveReverseDependencies(packageEntries: Seq[PackageEntry]): Map[PackageEntry, Set[PackageEntry]] =
      val packagesWithDependencyNames: Seq[(PackageEntry, Set[String])] =
        packageEntries.map { pkg =>
          val packageDependencyNames = pkg.dependencies.flatMap(_.toSet)
          pkg -> packageDependencyNames
        }

      packagesWithDependencyNames
        .flatMap((pkg, dependencyNames) =>
          dependencyNames
            .flatMap(dependencyName => packagesByName.get(dependencyName))
            .map(pkgToDependOn => pkgToDependOn -> pkg)
        )
        .toSet
        .groupMap((pkgToDependOn, _) => pkgToDependOn)((_, dependency) => dependency)
    end resolveReverseDependencies

    def resolveDependencies(dependencyNames: Set[Dependency[String]]): Set[Dependency[PackageReference]] =
      dependencyNames.map(dependencyName =>
        dependencyName.map { pkgName =>
          packagesByName
            .get(pkgName)
            .fold(PackageReference.Unknown(pkgName))(pkgEntry => PackageReference.Known(pkgEntry.id, pkgEntry.name))
        }
      )

    packageEntries.map { packageEntry =>
      val dependencies: Set[Dependency[PackageReference]] = resolveDependencies(packageEntry.dependencies)
      val reverseDependencies: Set[PackageReference] = reverseDependencyGraph
        .get(packageEntry)
        .getOrElse(Set.empty)
        .map(pe => PackageReference.Known(pe.name, pe.name))

      Package(packageEntry.id, packageEntry.name, packageEntry.description, dependencies, reverseDependencies)
    }
  end entriesToPackages

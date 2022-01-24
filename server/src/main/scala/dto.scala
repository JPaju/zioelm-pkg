import zio.json.*

case class PackageDTO(id: String, name: String)

case class PackageDetailsDTO(
    id: String,
    name: String,
    description: String,
    dependencies: Set[DependencyDTO],
    reverseDependencies: Set[DependencyDTO],
  )

// Cannot use enum here because zio-json lacks support for them
@jsonDiscriminator("type") sealed trait DependencyDTO
@jsonHint("known") case class KnonwPackageDTO(id: String, name: String)         extends DependencyDTO
@jsonHint("unknown") case class UnknownPackageDTO(name: String)                 extends DependencyDTO
@jsonHint("alternatives") case class OneOfDTO(alternatives: Set[DependencyDTO]) extends DependencyDTO

object PackageDTO:
  def fromPackage(pkg: Package): PackageDTO =
    PackageDTO(pkg.name, pkg.name)

  given JsonEncoder[PackageDTO] = DeriveJsonEncoder.gen[PackageDTO]

object PackageDetailsDTO:
  def fromPackage(pkg: Package): PackageDetailsDTO =
    PackageDetailsDTO(
      id = pkg.id,
      name = pkg.name,
      description = pkg.description,
      dependencies = pkg.dependencies.map(DependencyDTO.fromDependency),
      reverseDependencies = pkg.reverseDependencies.map(DependencyDTO.fromPackageReference),
    )

  given JsonEncoder[PackageDetailsDTO] = DeriveJsonEncoder.gen[PackageDetailsDTO]

object DependencyDTO:
  def fromPackageReference(reference: PackageReference): DependencyDTO =
    reference match
      case PackageReference.Known(id, name) => KnonwPackageDTO(id, name)
      case PackageReference.Unknown(name)   => UnknownPackageDTO(name)

  def fromDependency(dependency: Dependency[PackageReference]): DependencyDTO =
    dependency match
      case Dependency.Direct(dep) => fromPackageReference(dep)
      case Dependency.OneOf(deps) => OneOfDTO(deps.map(fromPackageReference))

  given JsonEncoder[DependencyDTO] = DeriveJsonEncoder.gen[DependencyDTO]

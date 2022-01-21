import zio.json.JsonEncoder
import zio.json.DeriveJsonEncoder

case class PackageDTO(name: String, description: String)

object PackageDTO:
  def fromPackage(pkg: Package): PackageDTO =
    PackageDTO(pkg.name, pkg.description)

  given JsonEncoder[PackageDTO] = DeriveJsonEncoder.gen[PackageDTO]

case class ConsicePackageDTO(name: String)

object ConsicePackageDTO:
  def fromPackage(pkg: Package): ConsicePackageDTO =
    ConsicePackageDTO(pkg.name)

  given JsonEncoder[ConsicePackageDTO] = DeriveJsonEncoder.gen[ConsicePackageDTO]

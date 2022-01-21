// ---------------------------- Packages ----------------------------
type PackageReference = Package | Dependency

case class Package(
    name: String,
    description: String,
    dependencies: Set[Dependency],
    reverseDependencies: Set[Dependency],
  )

enum Dependency:
  case Versioned(name: String, version: String)
  case UnVersioned(name: String)
  case Alternatives(deps: Seq[Dependency])

// ---------------------------- Control file ----------------------------

case class ControlFileParagraph(contents: Map[ControlFile.Field, ControlFile.FieldData])

object ControlFile:
  opaque type Field     = String
  opaque type FieldData = String

  def Field(str: String): Field         = str
  def FieldData(str: String): FieldData = str

  extension (field: Field) def name: String = field

  extension (fieldData: FieldData) def data: String = fieldData

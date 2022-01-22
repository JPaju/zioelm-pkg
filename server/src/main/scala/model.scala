// ---------------------------- Packages ----------------------------
case class Package(
    id: String,
    name: String,
    description: String,
    dependencies: Set[Dependency[PackageReference]],
    reverseDependencies: Set[PackageReference], // A.k.a dependents
  )

enum Dependency[A]:
  case Direct(dependency: A)
  case OneOf(alternatives: Set[A]) // TODO NonEmpty collection

  def toSet: Set[A] = this match
    case Direct(d) => Set(d)
    case OneOf(as) => as

  def map[B](f: A => B): Dependency[B] = this match
    case Direct(d) => Direct(f(d))
    case OneOf(as) => OneOf(as.map(f))

enum PackageReference:
  case Known(id: String, name: String)
  case Unknown(name: String)

// ---------------------------- Control file ----------------------------

case class ControlFileParagraph(contents: Map[ControlFile.Field, ControlFile.FieldData])

object ControlFile:
  opaque type Field     = String
  opaque type FieldData = String

  def Field(str: String): Field         = str
  def FieldData(str: String): FieldData = str

  extension (field: Field) def name: String = field

  extension (fieldData: FieldData) def data: String = fieldData

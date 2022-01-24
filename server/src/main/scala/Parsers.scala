import zio.NonEmptyChunk

object ControlFileParser:
  def parseParagraph(paragraph: String): ControlFileParagraph =
    def loop(rows: Seq[String]): Seq[(ControlFile.Field, ControlFile.FieldData)] =
      rows match
        case currentRow +: followingRows =>
          currentRow match
            case s"$fieldName:$firstDataRow" =>
              val (continuationRows, leftOverRows) = followingRows.span(_.startsWith(" "))

              val leftTrimmedFirstRow = firstDataRow.replaceAll("^\\s+", "").nn
              val trimmedContinuationRows = continuationRows
                .map(_.trim.nn)
                .filter(_.exists(_.isLetterOrDigit))
              val fieldData = (leftTrimmedFirstRow +: trimmedContinuationRows).mkString(" ")

              val dataField = ControlFile.Field(fieldName) -> ControlFile.FieldData(fieldData)
              dataField +: loop(leftOverRows)
            case _ => Seq.empty // Row format was not colon-separated key-value pairs

        case Seq() => Seq.empty // Base case
    end loop

    val rows = paragraph.split('\n').toIndexedSeq
    ControlFileParagraph(loop(rows).toMap)

end ControlFileParser

object DependencyParser:
  def parseDependencies(dependencyString: String): Set[Dependency[String]] =
    dependencyString
      .split(',')
      .map(_.trim.nn)
      .filter(_.nonEmpty)
      .map(parseDependencyEntry)
      .toSet

  private def parseDependencyEntry(dependencyEntry: String): Dependency[String] =
    val dependencies = parseDependency(dependencyEntry)

    dependencies.length match
      case 1 => Dependency.Direct(dependencies.head)
      case _ => Dependency.OneOf(dependencies.toSet)

  private def parseDependency(str: String): NonEmptyChunk[String] =
    str match
      case s"$current | $rest" => parseDependency(rest) ++ parseDependency(current)
      case s"$last ($version)" => NonEmptyChunk(last)
      case last                => NonEmptyChunk(last)

end DependencyParser

/** Package parsed from control file, with limited information about dependencies
  */
case class PackageEntry(name: String, description: String, dependencies: Set[Dependency[String]]):
  def id = name // Use name as id since it should be unique

object PackageParser:
  private val nameField         = ControlFile.Field("Package")
  private val descriptionField  = ControlFile.Field("Description")
  private val dependenciesField = ControlFile.Field("Depends")

  def fromControlfileParagraph(controlFile: ControlFileParagraph): Either[ControlFileParagraph, PackageEntry] =
    val entries = controlFile.contents

    val dependencies = entries
      .get(dependenciesField)
      .map(_.data)
      .map(DependencyParser.parseDependencies)
      .getOrElse(Set.empty)
      .toSet

    val nameOption        = entries.get(nameField)
    val descriptionOption = entries.get(descriptionField)

    (nameOption, descriptionOption) match
      case (Some(name), Some(description)) => Right(PackageEntry(name.data, description.data, dependencies))
      case _                               => Left(controlFile)

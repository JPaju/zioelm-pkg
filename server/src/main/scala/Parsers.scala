object ControlFileParser:
  def parseParagraph(paragraph: String): ControlFileParagraph =
    def loop(rows: Seq[String]): Seq[(ControlFile.Field, ControlFile.FieldData)] =
      rows match
        case currentRow +: followingRows =>
          currentRow match
            case s"$fieldName:$firstDataRow" =>
              val (continuationRows, leftOverRows) = followingRows.span(_.startsWith(" "))

              val leftTrimmedFirstRow = firstDataRow.replaceAll("^\\s+", "").nn
              val fieldData           = (leftTrimmedFirstRow +: continuationRows).mkString("\n")

              val dataField = ControlFile.Field(fieldName) -> ControlFile.FieldData(fieldData)
              dataField +: loop(leftOverRows)
            case _ => Seq.empty // Row format was not colon-separated key-value pairs

        case Seq() => Seq.empty // Base case
    end loop

    val rows = paragraph.split('\n').toIndexedSeq
    ControlFileParagraph(loop(rows).toMap)

end ControlFileParser

object DependencyParser:
  def parseDependencies(dependencyString: String): Seq[Dependency] =
    dependencyString
      .split(',')
      .toIndexedSeq
      .map(_.trim.nn)
      .filter(_.nonEmpty)
      .map(str => parseDependency(str))

  private def parseDependency(dependencyField: String): Dependency =
    dependencyField match
      case s"$current | $rest" => parseAlternatives(current, rest)
      case s"$name ($version)" => Dependency.Versioned(name, version)
      case name                => Dependency.UnVersioned(name)

  private def parseAlternatives(firstAlternativeStr: String, restAlternativesStr: String): Dependency =
    val firstAlternative = parseDependency(firstAlternativeStr)
    val restAlternatives = parseDependency(restAlternativesStr)

    restAlternatives match
      case Dependency.Alternatives(rest) => Dependency.Alternatives(firstAlternative +: rest)
      case lastAlternative               => Dependency.Alternatives(Seq(firstAlternative, lastAlternative))

end DependencyParser

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

/** Intermediate package representation without reverse dependencies, because those are not specified in control file
  */
case class PackageEntry(name: String, description: String, dependencies: Set[Dependency]):
  def toPackage(reverseDependencies: Set[Dependency]): Package =
    Package(name, description, dependencies, reverseDependencies)

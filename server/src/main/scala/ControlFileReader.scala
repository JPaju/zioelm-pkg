import zio.*
import zio.blocking.*
import zio.stream.*
import java.nio.file.Path

trait ControlFileReader:
  def readFile(path: Path): ZStream[Any, Throwable, ControlFileParagraph]

object ControlFileReader:
  def readFile(path: Path): ZStream[Has[ControlFileReader], Throwable, ControlFileParagraph] =
    ZStream.serviceWithStream(_.readFile(path))

  val live = (LiveControlFileReader(_)).toLayer[ControlFileReader]

class LiveControlFileReader(blocking: Blocking.Service) extends ControlFileReader:
  private val paragraphSeparator = "\n\n"

  def readFile(path: Path): ZStream[Any, Throwable, ControlFileParagraph] =
    ZStream
      .fromFile(path)
      .aggregate(Transducer.utf8Decode)
      .aggregate(Transducer.splitOn(paragraphSeparator))
      .map(ControlFileParser.parseParagraph)
      .provide(Has(blocking))

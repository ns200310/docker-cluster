import org.apache.spark.sql.SparkSession
import org.apache.spark.rdd.RDD

object LanguageIdentifier {

  private val indicatorsss = Map(
      "english" -> Set("the", "and", "a", "to", "of", "in", "is"),
      "french" -> Set("le", "la", "un", "une", "et", "de", "l", "est"),
      "german" -> Set("der", "die", "das", "und", "ist", "von", "in")
  )

  def main(args: Array[String]): Unit = {
    

    val inputPath = "hdfs://namenode:9000/*.txt"

    val spark = SparkSession.builder
      .appName("BasicLanguageDetector")
      .master("local[*]")
      .getOrCreate()

    val sc = spark.sparkContext

    try {
      val lRdd: RDD[String] = sc.textFile(s"$inputPath")

      val worRdd: RDD[String] = lRdd
        .flatMap(line => line.split("[\\s.,;!?]+"))
        .map(_.toLowerCase)
        .filter(_.nonEmpty)
        // ("the", 1) ("the", 1)

      val lCountsRdd: RDD[(String, Int)] = worRdd.flatMap { word =>
          indicatorsss.flatMap { case (lang, indicators) =>
              if (indicators.contains(word)) {
                  Some((lang, 1))
              } else {
                  None
              }
          }
      }

      val totalLangCounts: RDD[(String, Int)] = lCountsRdd.reduceByKey(_ + _)

      val res: Array[(String, Int)] = totalLangCounts.collect()

      if (res.isEmpty) {
          println("No indicator words found.")
      } else {
          println("\nIndicator Word Counts:")
          res.foreach { case (lang, count) =>
              println(s"| ${lang.capitalize}: $count hits")
          }

          val (mostCommonLanguage, maxCount) = res.maxBy(_._2)

          println(s"Lang: ${mostCommonLanguage.toUpperCase} with $maxCount of words")
      }

    } catch {
      case e: Exception =>
        System.err.println(s"Error: ${e.getMessage}")
        e.printStackTrace()
    } finally {
      spark.stop()
    }
  }
}
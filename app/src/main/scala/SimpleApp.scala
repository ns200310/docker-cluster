import org.apache.spark.sql.SparkSession
import org.apache.spark.rdd.RDD

object LanguageIdentifier {

  val englishWords = Set("the", "a", "and", "of", "to", "in", "is", "it", "that", "was")
  val frenchWords  = Set("le", "la", "les", "de", "des", "un", "une", "est", "et", "il")
  val germanWords  = Set("der", "die", "das", "und", "ein", "eine", "ist", "in", "von", "zu")

  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder()
      .appName("HdfsLanguageIdentifier")
      .getOrCreate()

    val sparkContext = spark.sparkContext

    val hadoopPath = "hdfs://namenode:9000/*.txt"

    println(s"Processing files from: $hadoopPath")

    try {
      val textFileLines = sparkContext.textFile(hadoopPath)

      val wordCount: RDD[(String, Int)] = textFileLines
        .flatMap(sentence => sentence.split("\\W+")) 
        .map(processedWord => processedWord.toLowerCase)
        .filter(processedWord => processedWord.nonEmpty && processedWord.length > 1)
        .map(processedWord => (processedWord, 1))
        .reduceByKey(_ + _)
        .cache()

      val wordPredictionArray = wordCount.map(_.swap).sortByKey(ascending = false).first()
      val wordPrediction: String = wordPredictionArray._2
      val wordPredictionCount: Int = wordPredictionArray._1


      var res: String = "Could not determine (Word not in primary word)"
      
      if (englishWords.contains(wordPrediction)) {
        res = "English"
      } else if (germanWords.contains(wordPrediction)) {
        res = "German"
      } else if (frenchWords.contains(wordPrediction)) {
        res = "French"
      } 
      
      if (res.contains("Could not determine")) {
          
          println(s"'$wordPrediction' is not a primary word. Checking aggregate counts...")

          val indicatorCounts = wordCount.filter { case (word, count) => 
            englishWords.contains(word) || frenchWords.contains(word) || germanWords.contains(word)
          }.collectAsMap()
          
          val totalEnglishWordCount = englishWords.map(indicatorCounts.getOrElse(_, 0)).sum
          val totalFrenchCount  = frenchWords.map(indicatorCounts.getOrElse(_, 0)).sum
          val totalGermanCount  = germanWords.map(indicatorCounts.getOrElse(_, 0)).sum

          val totalCounts = Map(
              "English" -> totalEnglishWordCount, 
              "French"  -> totalFrenchCount, 
              "German"  -> totalGermanCount
          )
          
          val (bestMatchLanguage, bestMatchCount) = totalCounts.maxBy(_._2)
          
          if (bestMatchCount > 0) {
              res = s"$bestMatchLanguage (by aggregate indicator count: $bestMatchCount)"
          } else {
              res = "Could not determine (No indicator words found)"
          }
           
          println(s"English: $totalEnglishWordCount, French: $totalFrenchCount, German: $totalGermanCount")
      }


      println(s"The overall most used word is: '${wordPrediction}' with $wordPredictionCount occurrences.")
      println(s"The most common language in the directory is pred to be: $res")

    } catch {
      case e: Exception =>
        println(s"Error: ${e.getMessage}")
    } finally {
      spark.stop()
    }
  }
}
import org.apache.spark.sql.SparkSession

object HdfsWordCount {
  def main(args: Array[String]): Unit = {
    // 1. Initialize SparkSession
    // This is the entry point for all functionality in Spark
    val spark = SparkSession
      .builder()
      .appName("HdfsMostUsedWord")
      .getOrCreate()

    // Import the Spark context (sc) from the SparkSession
    val sc = spark.sparkContext
    
    // Define the HDFS path pattern for your files (1, 2, 3)
    // **IMPORTANT: Adjust this path to your actual HDFS directory.**
    val hdfsPath = "hdfs://namenode:9000/*.txt"

    // 2. Read the text files from HDFS into an RDD
    // textFile automatically handles glob patterns like *
    val lines = sc.textFile(hdfsPath)

    // 3. Perform the Word Count logic
    val wordCounts = lines
      // Split each line into words using a regular expression for non-word characters
      // flatMap flattens the resulting array of words into a single RDD of words
      .flatMap(line => line.split("\\W+")) 
      // Convert all words to lowercase for accurate counting
      .map(_.toLowerCase)
      // Filter out any empty strings that may result from splitting/cleaning
      .filter(_.nonEmpty)
      // Map each word to a (word, 1) tuple
      .map(word => (word, 1))
      // Reduce by key: sum the counts for each word
      .reduceByKey(_ + _)

    // 4. Find the most used word
    // Swap (word, count) to (count, word)
    val sortedWordCounts = wordCounts.map(_.swap)
      // Sort in descending order by the count (key)
      .sortByKey(ascending = false)

    // 5. Get the top result (the most frequent word and its count)
    // collect() is used to bring the result back to the driver, only use on small results!
    val mostUsedWord = sortedWordCounts.first()

    // 6. Print the result
    println("------------------------------------------")
    println(s"File Path Processed: $hdfsPath")
    println(s"The most used word is: '${mostUsedWord._2}' with ${mostUsedWord._1} occurrences.")
    println("------------------------------------------")

    // 7. Stop the SparkSession
    spark.stop()
  }
}
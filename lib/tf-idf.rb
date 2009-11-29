# Tf-idf class implementing http://en.wikipedia.org/wiki/Tf-idf.
#
# The library constructs an IDF corpus and stopword list either from
# documents specified by the client, or by reading from input files.  It
# computes IDF for a specified term based on the corpus, or generates
# keywords ordered by tf-idf for a specified document.
#
# @author Marc Chung <mchung@gmail.com>
# @see http://en.wikipedia.org/wiki/Tf-idf Term frequency-inverse document frequency
class TfIdf

  # @return [Integer] The total number of documents in the tf-idf corpus.
  attr_accessor :num_docs
  
  # @return [Hash<String, Integer>] A histogram of terms and their term frequency.
  attr_accessor :term_num_docs
  
  # @return [Array<String>] An array of stopwords.
  attr_accessor :stopwords
  
  # @return [Float] The default value returned when a term is not found in the tf-idf corpus.
  attr_accessor :idf_default
  
  DEFAULT_IDF = 1.5
  
  ##
  # Initialize the tf-idf dictionary.  
  #   
  # If a corpus file is supplied, reads the idf dictionary from it, in the
  # format of:
  #  # of total documents
  #  term: # of documents containing the term
  # 
  # If a stopword file is specified, reads the stopword list from it, in
  # the format of one stopword per line.
  # 
  # The DEFAULT_IDF value is returned when a query term is not found in the
  # IDF corpus.
  #
  # @param [String] corpus_filename The disk location of the IDF corpus.
  # @param [String] stopword_filename The disk location of the stopword list.
  # @param [Float] default_idf The value returned when a term is not found in the IDF corpus.
  # @raise ["Corpus Not Found"] Thrown when the corpus isn't found.
  # @raise ["Stopwords Not Found"] Thrown when the stopwords list isn't found.
  # @return [TfIdf] A TfIdf instance loaded with the corpus.
  def initialize(corpus_filename = nil, stopword_filename = nil, default_idf = DEFAULT_IDF)
    self.num_docs = 0
    self.term_num_docs = {} 
    self.stopwords = []
    self.idf_default = default_idf

    raise "Corpus not found" if corpus_filename && !File.exists?(corpus_filename)    
    if corpus_filename
      entries = File.read(corpus_filename).entries
      self.num_docs = entries.shift.strip.to_i
      entries.each do |line|
        tokens = line.split(":")
        term = tokens[0].strip
        frequency = tokens[1].strip.to_i
        self.term_num_docs[term] = frequency
      end
    end
    
    raise "Stopwords not found" if stopword_filename && !File.exists?(stopword_filename)
    if stopword_filename
      self.stopwords = File.read(stopword_filename).entries.collect{|x| x.strip}
    end
  end
  
  ## 
  # Convenience method for creating a TfIdf instance.
  # 
  # @param [String] corpus_filename The disk location of the IDF corpus.
  # @return [TfIdf] A TfIdf instance loaded with the corpus.
  def self.from_corpus(corpus_filename, default_idf = DEFAULT_IDF)
    self.new(corpus_filename, nil, default_idf)
  end
  
  ##
  # Breaks a string into tokens. This implementation matches whole words.
  # Clients may wish to override this behaviour with their own tokenization.
  # strategy.
  #
  # @param [String] input String representation of a document
  # @return [Array<String>] A list of tokens
  def get_tokens(input)
    # str.split().collect{|x| x if x =~ /[A-Za-z]+/}.compact
    input.split.select{|x| x =~ /<a.*?\/a>|<[^\>]*>|[\w'@#]+/}
  end
  
  ##
  # Add terms in the specified document to the IDF corpus.
  #
  # @param [String] input String representation of a document.
  def add_input_document(input)
    self.num_docs += 1
    token_set = get_tokens(input).uniq
    token_set.each do |term|
      if self.term_num_docs[term]
        self.term_num_docs[term] += 1
      else
        self.term_num_docs[term] = 1
      end
    end
  end
  
  ##
  # Saves the tf-idf corpus and stopword list to the specified file.
  # 
  # A word is a stopword if it occurs in more than stopword_threshold% of num_docs.
  # A threshold of 0.4, means that the word must occur in more than 40% of the documents.
  #
  # @param [String] idf_filename Filename.
  # @param [String] stopword_filename Filename.
  # @param [Float] stopword_percentage_threshold Stopword threshold. Lower threshold lower criteria.
  def save_corpus_to_file(idf_filename, stopword_filename, stopword_percentage_threshold = 0.01)
    File.open(idf_filename, "w") do |file|
      file.write("#{self.num_docs}\n")
      self.term_num_docs.each do |term, num_docs|
        file.write("#{term}: #{num_docs}\n")
      end
    end
    
    File.open(stopword_filename, "w") do |file|
      sorted_term_num_docs = sort_by_tfidf(self.term_num_docs)
      sorted_term_num_docs.each do |term, num_docs|
        # pp [term, num_docs, stopword_percentage_threshold, self.num_docs, stopword_percentage_threshold * self.num_docs, ]
        if num_docs > stopword_percentage_threshold * self.num_docs
          file.write("#{term}\n")
        end
      end
    end
  end

  ##
  # Retrieves the IDF for the specified term. 
  # 
  # This is computed with:
  #   logarithm of ((number of documents in corpus) divided by 
  #                 (number of documents containing this term)).
  #
  # @param [String] term A term in the IDF corpus.
  # @return [Float] The IDF for the specified term.
  def idf(term)
    if self.stopwords.include?(term)
      return 0
    end
            
    if self.term_num_docs[term].nil?
      return self.idf_default
    end

    return Math.log((1 + self.num_docs).to_f / 
                    (1 + self.term_num_docs[term]))
  end

  ## 
  # Retrieve terms and corresponding tf-idf for the specified document.
  #
  # The returned terms are ordered by decreasing tf-idf.
  #
  # @param [String] curr_doc String representation of an existing document.
  # @return [Array] Terms ordered by decreasing tf-idf rank.
  def doc_keywords(curr_doc)
    tfidf = {}

    tokens = self.get_tokens(curr_doc)
    token_set = tokens.uniq
    token_set_sz = token_set.count
    
    token_set.each do |term|
      mytf = tokens.count(term).to_f / token_set_sz
      myidf = self.idf(term)
      tfidf[term] = mytf * myidf
    end

    sort_by_tfidf(tfidf)
  end

  ##
  # Returns a string representation of the tf-idf corpus. 
  # 
  # @return [String] Contains # docs, # term and frequency.
  def to_s
    {:num_docs => self.num_docs, :term_num_docs => self.term_num_docs.size}.inspect
  end
  
  ## 
  # Sorts terms by decreasing tf-idf.
  #
  # @example Sort by tf-idf
  #  "{'and'=>0.0025, 'fork'=>0.0025, 'the'=>0.37688590118819, 'spoon'=>1.0025}" #=>
  #  "[['spoon', 1.0025], ['the', 0.37688590118819], ['fork', 0.0025], ['and', 0.0025]]"
  # @return [Array<Array<String, Float>>] An array of term/IDF array pairs.
  def sort_by_tfidf(tfidf)
    tfidf.sort{|a, b| b[1] <=> a[1]}
  end

end
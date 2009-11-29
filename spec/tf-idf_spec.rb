require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "TF-IDF library" do

  before(:all) do
    @test_corpus = File.expand_path(File.dirname(__FILE__) + '/fixtures/tfidf_testcorpus.txt')
    @test_stopwords = File.expand_path(File.dirname(__FILE__) + '/fixtures/tfidf_teststopwords.txt')
    @default_idf_unittest = 1.0
  end

  it "should instantiate without args" do
    TfIdf.new
  end
  
  it "should report the correct number of documents" do
    my_tfidf = TfIdf.from_corpus(@test_corpus, @default_idf_unittest)
    my_tfidf.num_docs.should == 50
  end

  it "should report the correct number of terms" do
    my_tfidf = TfIdf.from_corpus(@test_corpus, @default_idf_unittest)
    my_tfidf.term_num_docs.size.should == 6
  end
  
  it "should query IDF for nonexistent terms" do
    my_tfidf = TfIdf.from_corpus(@test_corpus, @default_idf_unittest)
    my_tfidf.idf("nonexistent").should == @default_idf_unittest
    my_tfidf.idf("THE").should == @default_idf_unittest
  end
  
  it "should query IDF for existent terms" do
    my_tfidf = TfIdf.from_corpus(@test_corpus, @default_idf_unittest)
    my_tfidf.idf("a").should > my_tfidf.idf("the")
    my_tfidf.idf("girl").should == my_tfidf.idf("moon")
  end
  
  it "should retrieve keywords from a document, ordered by tf-idf" do
    my_tfidf = TfIdf.from_corpus(@test_corpus, 0.01)

    # Test retrieving keywords when there is only one keyword.
    keywords = my_tfidf.doc_keywords("the spoon and the fork")
    keywords[0][0].should == "the"
    
    # Test retrieving multiple keywords.
    keywords = my_tfidf.doc_keywords("the girl said hello over the phone")
    keywords[0][0].should == "girl"
    keywords[1][0].should == "phone"
    keywords[2][0].should == "said"
    keywords[3][0].should == "the"
  end

  it "should add input documents to an existing corpus" do
    my_tfidf = TfIdf.new(@test_corpus, nil, @default_idf_unittest)
    my_tfidf.idf("water").should == @default_idf_unittest
    my_tfidf.idf("moon").should == get_expected_idf(my_tfidf.num_docs, 1)
    my_tfidf.idf("said").should == get_expected_idf(my_tfidf.num_docs, 5)

    my_tfidf.add_input_document("water moon") # doesn't support commas
    
    my_tfidf.idf("water").should == get_expected_idf(my_tfidf.num_docs, 1)
    my_tfidf.idf("moon").should == get_expected_idf(my_tfidf.num_docs, 2)
    my_tfidf.idf("said").should == get_expected_idf(my_tfidf.num_docs, 5)
  end
  
  it "should add input documents to an empty corpus" do
    my_tfidf = TfIdf.new(nil, nil, @default_idf_unittest)
    my_tfidf.idf("moon").should == @default_idf_unittest
    my_tfidf.idf("water").should == @default_idf_unittest
    my_tfidf.idf("said").should == @default_idf_unittest

    my_tfidf.add_input_document("moon")
    my_tfidf.add_input_document("moon said hello")

    my_tfidf.idf("water").should == @default_idf_unittest
    my_tfidf.idf("said").should == get_expected_idf(my_tfidf.num_docs, 1)
    my_tfidf.idf("moon").should == get_expected_idf(my_tfidf.num_docs, 2)
  end
  
  it "should observe stopwords list" do
    my_tfidf = TfIdf.new(@test_corpus, @test_stopwords, @default_idf_unittest)    
    my_tfidf.idf("water").should == @default_idf_unittest
    my_tfidf.idf("moon").should == 0 # ignored
    my_tfidf.idf("said").should == get_expected_idf(my_tfidf.num_docs, 5)
    
    my_tfidf.add_input_document("moon")
    my_tfidf.add_input_document("moon and water")

    my_tfidf.idf("water").should == get_expected_idf(my_tfidf.num_docs, 1)
    my_tfidf.idf("moon").should == 0
    my_tfidf.idf("said").should == get_expected_idf(my_tfidf.num_docs, 5)
  end
  
  # Abstract out File IO
  # it "should write the contents of the TF/IDF corpus to disk" do
  #   my_tfidf = TfIdf.new(@test_corpus, @test_stopwords, @default_idf_unittest)    
  #   my_tfidf.save_corpus_to_file("foo.txt", "bar.txt", 0.3)
  #   stopwords = File.read("bar.txt").split
  # 
  #   stopwords.size.should == 2
  #   stopwords.should include("a")
  #   stopwords.should include("the")
  # end

end
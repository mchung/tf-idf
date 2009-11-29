Feature: Tf-Idf
  A user should be able to construct an IDF corpus

  Scenario: A corpus should contain the total number of documents
    Given I have loaded the sample corpus data set "tfidf_testcorpus.txt"
    Then I should have a total of "50" documents

  Scenario: A corpus should contain terms and the number of documents they are found in.
    Given I have loaded the sample corpus data set "tfidf_testcorpus.txt"
    Then I should have a total of "6" term/num_doc pairs

  Scenario: A corpus should query IDF for nonexistent terms
    Given I have loaded the sample corpus data set "tfidf_testcorpus.txt"
    Then I should get the default IDF for "nonexistent"
    Then I should get the default IDF for "THE"
    
  Scenario: A corpus should query IDF for existent terms
    Given I have loaded the sample corpus data set "tfidf_testcorpus.txt"
    Then the IDF for "a" should be greater than the IDF for "the"
    Then the IDF for "girl" should be equal to the IDF for "moon"

  Scenario: A corpus should retrieve keywords from a document, ordered by tf-idf"
    Given the default IDF is set to "0.01"
    And I have loaded the sample corpus data set "tfidf_testcorpus.txt"
    Given the keywords "the spoon and the fork"
    Then "the" should be located at "0", "0"
    Given the keywords "the girl said hello over the phone"
    Then "girl" should be located at "0", "0"
    Then "phone" should be located at "1", "0"
    Then "said" should be located at "2", "0"
    Then "the" should be located at "3", "0"

  # Scenario: A corpus should add input documents to an existing corpus"
  #   Given I have loaded the sample corpus data set "tfidf_testcorpus.txt"
  #   Then I should get the default IDF for "water"
  #   Then I should get the expected IDF for "moon" when it has "1" occurrence
  #   Then I should get the expected IDF for "said" when it has "5" occurrences


    # it "should add input documents to an existing corpus" do
    #   my_tfidf = TfIdf.new(@test_corpus, nil, @default_idf_unittest)
    #   my_tfidf.idf("water").should == @default_idf_unittest
    #   my_tfidf.idf("moon").should == get_expected_idf(my_tfidf.num_docs, 1)
    #   my_tfidf.idf("said").should == get_expected_idf(my_tfidf.num_docs, 5)
    # 
    #   my_tfidf.add_input_document("water moon") # doesn't support commas
    # 
    #   my_tfidf.idf("water").should == get_expected_idf(my_tfidf.num_docs, 1)
    #   my_tfidf.idf("moon").should == get_expected_idf(my_tfidf.num_docs, 2)
    #   my_tfidf.idf("said").should == get_expected_idf(my_tfidf.num_docs, 5)
    # end
    # 
    # it "should add input documents to an empty corpus" do
    #   my_tfidf = TfIdf.new(nil, nil, @default_idf_unittest)
    #   my_tfidf.idf("moon").should == @default_idf_unittest
    #   my_tfidf.idf("water").should == @default_idf_unittest
    #   my_tfidf.idf("said").should == @default_idf_unittest
    # 
    #   my_tfidf.add_input_document("moon")
    #   my_tfidf.add_input_document("moon said hello")
    # 
    #   my_tfidf.idf("water").should == @default_idf_unittest
    #   my_tfidf.idf("said").should == get_expected_idf(my_tfidf.num_docs, 1)
    #   my_tfidf.idf("moon").should == get_expected_idf(my_tfidf.num_docs, 2)
    # end
    # 
    # it "should observe stopwords list" do
    #   my_tfidf = TfIdf.new(@test_corpus, @test_stopwords, @default_idf_unittest)    
    #   my_tfidf.idf("water").should == @default_idf_unittest
    #   my_tfidf.idf("moon").should == 0 # ignored
    #   my_tfidf.idf("said").should == get_expected_idf(my_tfidf.num_docs, 5)
    # 
    #   my_tfidf.add_input_document("moon")
    #   my_tfidf.add_input_document("moon and water")
    # 
    #   my_tfidf.idf("water").should == get_expected_idf(my_tfidf.num_docs, 1)
    #   my_tfidf.idf("moon").should == 0
    #   my_tfidf.idf("said").should == get_expected_idf(my_tfidf.num_docs, 5)
    # end
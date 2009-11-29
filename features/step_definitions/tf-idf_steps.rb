Before do
  @default_idf_unittest = 1.0
end

Given /^the default IDF is set to "([^\"]*)"$/ do |val|
  @default_idf_unittest = val.to_f
end

Given /^I have loaded the sample corpus data set "([^\"]*)"$/ do |corpus_filename|
  @corpus_filename = File.expand_path(File.dirname(__FILE__) + "/../../spec/fixtures/#{corpus_filename}")
  @my_tfidf = TfIdf.from_corpus(@corpus_filename, @default_idf_unittest)
end

Then /^I should have a total of "([^\"]*)" documents$/ do |total_doc_count|
  @my_tfidf.num_docs.should == total_doc_count.to_i
end

Then /^I should have a total of "([^\"]*)" term\/num_doc pairs$/ do |total_term_num_doc_count|
  @my_tfidf.term_num_docs.size.should == total_term_num_doc_count.to_i
end

Then /^I should get the default IDF for "([^\"]*)"$/ do |term|
  @my_tfidf.idf(term).should == @default_idf_unittest
end

Then /^the IDF for "([^\"]*)" should be greater than the IDF for "([^\"]*)"$/ do |term1, term2|
  @my_tfidf.idf(term1).should > @my_tfidf.idf(term2)
end

Then /^the IDF for "([^\"]*)" should be equal to the IDF for "([^\"]*)"$/ do |term1, term2|
  @my_tfidf.idf(term1).should == @my_tfidf.idf(term2)
end

Given /^the keywords "([^\"]*)"$/ do |keywords|
  @keywords = @my_tfidf.doc_keywords(keywords)
end

Then /^"([^\"]*)" should be located at "([^\"]*)", "([^\"]*)"$/ do |term, x, y|
  @keywords[x.to_i][y.to_i].should == term
end


# Then /^I should get the expected IDF for "([^\"]*)"$/ do |arg1|
#   pending
# end

def get_expected_idf(num_docs_total, num_docs_term)
  Math.log((1 + num_docs_total).to_f / (1 + num_docs_term))
end
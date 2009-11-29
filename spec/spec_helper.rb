$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'tf-idf'
require 'spec'
require 'spec/autorun'
require 'pp'

Spec::Runner.configure do |config|
end

def get_expected_idf(num_docs_total, num_docs_term)
  Math.log((1 + num_docs_total).to_f / (1 + num_docs_term))
end
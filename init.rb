begin
  require 'aws/s3'
rescue LoadError
  raise "aws/s3 gem needs to be installed. gem install aws-s3"
end
require File.dirname(__FILE__) + '/lib/heroku_s3assets'
require File.dirname(__FILE__) + '/lib/help'
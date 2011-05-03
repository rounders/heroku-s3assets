begin
  require 'aws/s3'
rescue LoadError
  raise "aws/s3 gem needs to be installed. gem install aws-s3"
end

begin 
  require 'progress_bar'
rescue LoadError
  raise "progress_bar gem needs to be installed. gem install progress_bar"
end

require File.dirname(__FILE__) + '/lib/heroku/command/s3assets'
require File.dirname(__FILE__) + '/lib/help'
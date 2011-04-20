module Heroku::Command
  class S3assets < BaseWithApp
    def pull
      pull_s3_assets
    end

    private
    def assets_path
      return @assets_path unless @assets_path.nil?
      
      output = extract_option("--output")
      if output
        @assets_path = File.join(Dir.pwd, output)
        raise "#{assets_path} does not exist" unless File.directory?(@assets_path)
      else
        # use default
        @assets_path = File.join(Dir.pwd, 'public/system')
      end
      
      @assets_path
    end
    
    def bucket
      return @bucket unless @bucket.nil?
      b = extract_option("--bucket")
      @bucket = b ? b : heroku.config_vars(app)['S3_BUCKET']
      raise "please specify a bucket via S3_BUCKET config var or through --bucket <bucketname>" if @bucket.nil?

      return @bucket
    end
    
    def pull_s3_assets
      display("===================================================================================")
      display("Warning: files in '#{assets_path}' will be overwritten and will not be recoverable.")
      display("===================================================================================")
      
      if confirm_command
        copy_all_s3_assets
      end
    end
    
    def s3_config
      @s3_config ||= {
        :key => heroku.config_vars(app)['S3_KEY'],
        :secret => heroku.config_vars(app)['S3_SECRET'],
        :bucket => bucket 
      }
    end
    
    def copy_all_s3_assets
      AWS::S3::Base.establish_connection!(:access_key_id => s3_config[:key], :secret_access_key => s3_config[:secret])
      bucket = AWS::S3::Bucket.find(s3_config[:bucket])
      puts "There are #{bucket.objects.size} items in the #{s3_config[:bucket]} bucket"

      bucket.objects.each do |object|
        display "===== Saving #{object.key}"
        object_path = File.join(assets_path,object.key)
        path = File.dirname(object_path)
        filename = File.basename(object_path)
        FileUtils::mkdir_p path, :verbose => false
        open(object_path, 'w') do |f|
          f.puts object.value
        end
      end
      
    rescue Exception => ex
      puts "Error copying from s3: #{ex.message}"
      puts ex.backtrace
      ""
    end
    
    
  end
end
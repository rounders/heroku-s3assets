module Heroku::Command
  class S3assets < BaseWithApp
    
    # s3assets:pull
    #
    # pull assets from s3 to local app
    #
    # 
    # --key                # specify the s3 key, default is app config param S3_KEY
    # --secret             # specify the s3 secret key, default is app config param S3_SECRET
    # --bucket             # specify the s3 bucket to copy, default is app config param S3_BUCKET
    # --output             # specify output directory, relative to app root. Default is public/system
    #
    
    def pull
      opts = parse_options

      display("===================================================================================")
      display("Warning: files in '#{opts[:output_path]}' will be overwritten and will not be recoverable.")
      display("===================================================================================")
      
      if confirm_command
        copy_s3_bucket(opts[:s3_key], opts[:s3_secret], opts[:s3_bucket], opts[:output_path])
      end
    end

    private
    
    def copy_s3_bucket(s3_key, s3_secret, s3_bucket, output_path)
      AWS::S3::Base.establish_connection!(:access_key_id => s3_key, :secret_access_key => s3_secret)
      bucket = AWS::S3::Bucket.find(s3_bucket)
      puts "There are #{bucket.objects.size} items in the #{s3_bucket} bucket"

      bucket.objects.each do |object|
        dest = File.join(output_path,object.key)
        copy_s3_object(object,dest)
      end
    end
    
    def copy_s3_object(s3_object, to)
      
      FileUtils::mkdir_p File.dirname(to), :verbose => false

      filesize = s3_object.about['content-length'].to_f
      display "Saving #{s3_object.key} (#{filesize} bytes):"
      
      bar = ProgressBar.new(filesize, :percentage, :counter)

      open(to, 'w') do |f|
        s3_object.value do |chunk|
          bar.increment! chunk.size
          f.puts chunk
        end
      end
      
      display "\n=======================================\n"

    end
    
    def parse_options
      opts = {}
      opts[:s3_key] = extract_option("--key") || heroku.config_vars(app)['S3_KEY']
      raise(CommandFailed, "please specify an S3 key via S3_KEY config var or through --key <s3key>") if opts[:s3_key].nil?

      opts[:s3_secret] = extract_option("--secret") || heroku.config_vars(app)['S3_SECRET']
      raise(CommandFailed, "please specify an S3 secret key via S3_SECRET config var or through --secret <s3secret>") if opts[:s3_secret].nil?

      opts[:s3_bucket] =  extract_option("--bucket") || heroku.config_vars(app)['S3_BUCKET']
      raise(CommandFailed, "please specify a bucket via S3_BUCKET config var or through --bucket <bucketname>") if opts[:s3_bucket].nil?

      opts[:output_path] = File.join(Dir.pwd, extract_option("--output") || 'public/system')
      if !File.directory?(opts[:output_path])
        print "#{opts[:output_path]} does not exist. "
        if confirm("Would you like to create it? (y/N):")
          FileUtils::mkdir_p opts[:output_path]
        else
          raise(CommandFailed, "please create the output path or specify a different one")
          exit;
        end
      end
      
      opts
    end
    
    
  end
end
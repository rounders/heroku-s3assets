Heroku::Command::Help.group('s3assets Command') do |group|
  group.command('s3assets:pull [--output <path>]', 'download all s3 assets to <path>. Default <path> is public/system.')
end
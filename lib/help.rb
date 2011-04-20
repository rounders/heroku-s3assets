Heroku::Command::Help.group('s3_assets Command') do |group|
  group.command('s3_assets:pull [--output <path>]', 'download all s3 assets to <path>. Default <path> is public/system.')
end
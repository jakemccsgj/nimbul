task "resque:setup" => :environment do
  Grit::Git.git_timeout = 10.minutes
end

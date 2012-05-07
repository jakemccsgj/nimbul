module ProviderAccountRefresh
  class Accounts
    include Resque::Plugins::UniqueJob
    @loner_ttl = 60 #Timeout lock after a minute
    class << self
      def perform
        ProviderAccount.all.each do |acc|
          Resque.enqueue(ProviderAccountRefresh::Account, acc.id)
        end
      end
      def queue
        :provider_account_refresh_jobs
      end
    end
  end

  class Account
    include Resque::Plugins::UniqueJob
    @loner_ttl = 60 #Timeout lock after a minute
    class << self
      def perform id
        ProviderAccount[id].refresh
      end

      def queue
        :provider_account_refresh
      end
    end
  end
end

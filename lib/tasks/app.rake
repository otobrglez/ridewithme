require 'webrick'
require 'csv'

namespace :app do

  desc "Authenticate app with Facebook"
  task :authenticate => :environment do
    include WEBrick

    api_key = Rails.application.secrets[:facebook_app_id]
    app_secret = Rails.application.secrets[:facebook_app_secret]
    callback_url = Rails.application.secrets[:facebook_callback_url]
    @oauth = Koala::Facebook::OAuth.new(api_key, app_secret, callback_url)

    Launchy.open @oauth.url_for_oauth_code

    server = WEBrick::HTTPServer.new :Port => 4321, :DocumentRoot => Dir.pwd, :AccessLog => []

    trap 'INT' do
      server.shutdown
    end

    server.mount_proc '/authenticate' do |request, response|

      if request.query["code"]
        code = request.query["code"]
        access_token = @oauth.get_access_token_info(code)

        puts ""
        puts "AccessToken: #{access_token['access_token']}"
        puts ""
      else
        $stderr.puts "Not getting code!"
        exit 2
      end

      response.body = "<p>You can now close this window.</p>"
      server.shutdown
    end

    server.start
  end
end

namespace :groups do

  desc "Update groups info"
  task :update_all_info => :environment do
    groups = Group.all_with_info

    CSV.open(Group::GROUPS_WITH_INFO, "wb") do |c|
      groups.each do |g|
        c << g.fields.map! { |f| g.send(f) }
      end
    end
  end

  desc "Fetch feed by id"
  task :fetch_feed, [:id] => :environment do |task, options|
    id = options[:id]

    CSV.open(Rails.root.join(Group::GROUP_FEED % id), "wb", force_quotes: true) do |c|
      puts "Working on #{id}"
      items = Group.by_id(id).feed do |item|
        c << item.fields.map! { |f| item.send(f) }
      end
    end
  end

  desc "Fetch all feeds"
  task :fetch_feeds => :environment do
    Group.all do |g|
      id = g.id
      CSV.open(Rails.root.join(Group::GROUP_FEED % id), "wb", force_quotes: true) do |c|
        puts "Working on #{id}"
        i = 0
        items = Group.by_id(id).feed do |item|
          c << item.fields.map! { |f| item.send(f) }
          if i % 100 == 0
            puts "Index: #{i}"
          end

          i += 1
        end
      end
    end
  end

end

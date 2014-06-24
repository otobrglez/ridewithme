require 'csv'
require 'ostruct'

class Group < OpenStruct
  GROUPS_RAW = Rails.root.join 'data', 'groups.csv'
  GROUPS_WITH_INFO = Rails.root.join 'data', 'groups-info.csv'
  GROUP_FEED = "data/feed-%s.csv"

  def info
    Graph.get_object(id)
  end

  def feed
    feed = Graph.get_connections(id, "feed", limit: 200)
    api_error = false
    # page_count = 0

    begin
      feed.each do |i|
        yield process_item(i) if block_given?
      end unless feed.nil?

      begin
        feed = feed.next_page
        # page_count += 1
      rescue Exception => e
        api_error = true
      end

    end while api_error != true # and page_count < 1
  end

  def process_item item
    # puts item["id"]
    FeedItem.new(
      id: item["id"],
      user_id: item["from"]["id"],
      name: item["from"]["name"],
      message: item["message"],
      type: item["type"],
      updated_time: Chronic.parse(item["updated_time"]),
      created_time: Chronic.parse(item["created_time"])
    )
    # item
  end

  def fields
    @table.keys
  end

  class << self

    def by_id id
      Group.new(id: id)
    end

    def all &block
      CSV.read(GROUPS_RAW).map do |row|
        group = Group.new(id: row[0])
        yield group if block_given?
        group
      end
    end

    def all_with_info &block
      graph_infos = Graph.batch do |b|
        all.map(&:id).map do |id|
          b.get_object(id)
        end
      end

      graph_infos.map do |info|
        group = Group.new(
          id: info["id"],
          privacy: info["privacy"],
          user_id: info["owner"]["id"],
          updated_time: Chronic.parse(info["updated_time"]),
          name: info["name"],
        )

        yield group, info if block_given?
        group
      end
    end

  end
end

class FeedItem < OpenStruct
  def fields
    @table.keys
  end
end

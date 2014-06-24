class Graph
  extend Forwardable

  include Singleton

  attr_reader :graph

  def_delegators :@graph, :get_object, :get_connections, :batch

  def initialize
    # Koala::Utils.logger = Logger.new(STDOUT)
    @graph = Koala::Facebook::API.new(Graph.access_token)
  end

  class << self
    extend Forwardable
    def_delegators :instance, *Graph.instance_methods(false)

    def access_token
      ENV["FACEBOOK_ACCESS_TOKEN"]
    end
  end
end

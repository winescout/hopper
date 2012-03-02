module Hopper
  # A Source is a place where we can get a Project. Usually a version control
  # host.
  class Source
    # Load all sources.
    Dir["app/sources/*.rb"].each {|file| require file }

    # The URL of the Project.
    #
    # Returns a String.
    attr_accessor :url

    # Creates a new Source.
    #
    # Returns the Source.
    def initialize(url)
      @url = url
    end

    # The name of the Source.
    #
    # Returns a String.
    def self.name
      raise NotImplementedError
    end

    # The main URL of the Source.
    #
    # Returns a String.
    def self.url
      raise NotImplementedError
    end

    # The URL used to download this Source.
    #
    # Returns a String.
    def clone_url
      raise NotImplementedError
    end

    # Raised if the method hasn't been properly defined in the subclass.
    class NotImplementedError < StandardError ; end
  end
end
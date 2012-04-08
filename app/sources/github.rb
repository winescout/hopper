module Hopper
  class Github < Source
    # The name of the Source.
    #
    # Returns a String.
    def self.name
      "GitHub"
    end

    # The main URL of the Source.
    #
    # Returns a String.
    def self.url
      "https://github.com"
    end

    # An informal, unique name that we can give it. For GitHub, that's our
    # favorite nwo, like holman/hopper.
    #
    # Returns a String.
    def name
      url.split('/')[-2..-1].join('/')
    end

    # Spider the API to find non-forked Ruby projects.
    #
    # Returns nothing.
    def self.index
      key = "hopper:sources:github:page"
      page = $redis.get(key).to_i || 1

      # There's something like 6200 pages of unforked Ruby projects. Hax.
      (page..6200).each do |i|
        curl = `curl "http://github.com/api/v2/json/repos/search/fork:0?language=Ruby&start_page=#{i}" --silent`
        json = Yajl::Parser.parse(curl)

        $redis.set(key, i)
        import(json)
      end
    end

    # Import projects via JSON.
    #
    # json - The JSON-formatted return from the GitHub API.
    #
    # Returns nothing.
    def self.import(json)
      json['repositories'].each do |repository|
        Project.create(repository['url'])
      end
    end

    # The Git clone URL that lets us pull down this source.
    #
    # Returns a String.
    def clone_url
      "https://#{url}.git"
    end

    # The clone command needed to clone down this source.
    #
    # Returns a String.
    def clone_command
      "git clone #{clone_url} #{local_path}"
    end

    # The project metadata we fetch from the wire.
    #
    # TODO: This is getting run multiple times on each `metadata` call.
    #
    # Returns a Hash
    def metadata
      Yajl::Parser.parse(`curl https://api.github.com/repos/#{name} --silent`)
    end

    # The number of followers for this project.
    #
    # Returns an Integer.
    def followers
      metadata['watchers']
    end

    # The number of forks for this project.
    #
    # Returns an Integer.
    def forks
      metadata['forks']
    end

    # The number of open issues in this project.
    #
    # Returns an Integer.
    def open_issues
      metadata['open_issues']
    end
  end
end
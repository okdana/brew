module Hbc
  module Source
    class Tapped
      def self.me?(query)
        path_for_query(query).exist?
      end

      def self.path_for_query(query)
        # Repeating Hbc.all_tokens is very slow for operations such as
        # brew cask list, but memoizing the value might cause breakage
        # elsewhere, given that installation and tap status is permitted
        # to change during the course of an invocation.
        token_with_tap = Hbc.all_tokens.find { |t| t.split("/").last == query.sub(%r{\.rb$}i, "") }
        if token_with_tap
          user, repo, token = token_with_tap.split("/")
          Tap.fetch(user, repo).cask_dir.join("#{token}.rb")
        else
          Hbc.default_tap.cask_dir.join(query.sub(%r{(\.rb)?$}i, ".rb"))
        end
      end

      attr_reader :token

      def initialize(token)
        @token = token
      end

      def load
        path = self.class.path_for_query(token)
        PathSlashOptional.new(path).load
      end

      def to_s
        # stringify to fully-resolved location
        self.class.path_for_query(token).expand_path.to_s
      end
    end
  end
end

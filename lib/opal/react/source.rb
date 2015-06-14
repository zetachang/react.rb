require "react/source"

module Opal
  module React
    def self.bundled_path
      File.dirname(::React::Source.bundled_path_for("react-with-addons.js"))
    end
  end
end

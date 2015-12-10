module React
  class TopLevelRailsComponent
    include React::Component

    def self.search_path
      @search_path ||= [Module]
    end

    export_component

    param :component_name
    param :controller
    param :render_params

    backtrace :on

    def render
      paths_searched = []
      if params.component_name.start_with? "::"
        paths_searched << params.component_name.gsub(/^\:\:/,"")
        component = params.component_name.gsub(/^\:\:/,"").split("::").inject(Module) { |scope, next_const| scope.const_get(next_const, false) } rescue nil
        return present component, params.render_params if component && component.method_defined?(:render)
      else
        self.class.search_path.each do |path|
          # try each path + params.controller + params.component_name
          paths_searched << "#{path.name + '::' unless path == Module}#{params.controller}::#{params.component_name}"
          component = "#{params.controller}::#{params.component_name}".split("::").inject(path) { |scope, next_const| scope.const_get(next_const, false) } rescue nil
          return present component, params.render_params if component && component.method_defined?(:render)
        end
        self.class.search_path.each do |path|
          # then try each path + params.component_name
          paths_searched << "#{path.name + '::' unless path == Module}#{params.component_name}"
          component = "#{params.component_name}".split("::").inject(path) { |scope, next_const| scope.const_get(next_const, false) } rescue nil
          return present component, params.render_params if component && component.method_defined?(:render)
        end
      end
      raise "Could not find component class '#{params.component_name}' for params.controller '#{params.controller}' in any component directory. Tried [#{paths_searched.join(", ")}]"
    end
  end
end

class Module
  def add_to_react_search_path(replace_search_path = nil)
    if replace_search_path
      React::TopLevelRailsComponent.search_path = [self]
    elsif !React::TopLevelRailsComponent.search_path.include? self
      React::TopLevelRailsComponent.search_path << self
    end
  end
end

module Components
  add_to_react_search_path
end

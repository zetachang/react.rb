module React
  class NativeLibrary
    def self.renames_and_exclusions
      @renames_and_exclusions ||= {}
    end

    def self.libraries
      @libraries ||= []
    end

    def self.const_missing(name)
      if renames_and_exclusions.has_key? name
        if native_name = renames_and_exclusions[name]
          native_name
          native_component = `eval(#{native_name})` rescue nil
          React::API.import_native_component(name, native_component) and return name if native_component && `native_component != undefined`
        else
          super
        end
      else
        libraries.each do |library|
          native_name = "#{library}.#{name}"
          native_component = `eval(#{native_name})` rescue nil
          React::API.import_native_component(name, native_component) and return name if native_component && `native_component != undefined`
        end
        name
      end
    end

    def self.method_missing(n, *args, &block)
      name = n
      if name =~ /_as_node$/
        node_only = true
        name = name.gsub(/_as_node$/, "")
      end
      unless name = const_get(name)
        return super
      end
      React::RenderingContext.build_or_render(node_only, name, *args, &block)
    rescue
    end

    def self.imports(library)
      libraries << library
    end

    def self.rename(rename_list={})
      renames_and_exclusions.merge!(rename_list.invert)
    end

    def self.exclude(*exclude_list)
      renames_and_exclusions.merge(Hash[exclude_list.map {|k| [k, nil]}])
    end
  end
end

module Components
  class Todo
    include React::Component
    export_component

    params do
      requires :todo
    end

    def render
      li { "#{params[:todo]}" }
    end
  end
end

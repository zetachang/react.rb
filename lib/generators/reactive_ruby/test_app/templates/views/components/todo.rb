module Components
  class Todo
    include React::Component

    params do
      requires :todo
    end

    def render
      li { "#{params[:todo]}" }
    end
  end
end

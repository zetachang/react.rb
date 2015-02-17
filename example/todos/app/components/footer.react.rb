class Footer
  include React::Component
  
  def clear_completed
    Todo.completed.each { |t| t.destroy }
  end
  
  def render
    footer(id: "footer") do
      span(id: "todo-count") do
        strong { Todo.active.size }
        span { Todo.active.size == 1 ? ' item left' : ' items left' }
      end
      
      ul(id: "filters") do
        filters = [{href: "#/", filter: "all"}, 
                   {href: "#/active", filter: "active"}, 
                   {href: "#/completed", filter: "completed"}]
        filters.map do |item|
          link_class = params[:selectedFilter] == item[:filter] ? 'selected' : ''
          li { a(href: item[:href], class_name: link_class) { item[:filter].capitalize } }
        end
      end

      completed = Todo.completed.size
      
      if completed > 0
        button(id: "clear-completed") { "Clear completed (#{completed})" }.on(:click) { clear_completed }
      end
    end
  end
end
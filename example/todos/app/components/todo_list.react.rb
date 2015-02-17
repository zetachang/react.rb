class TodoList
  include React::Component
  
  def toggle_all
    distinct_status = Todo.all.map {|t| t.completed }.uniq
    
    if distinct_status.count == 1
      Todo.all.each {|t| t.update(:completed => !distinct_status[0]) }
    else # toggle all as completed
      Todo.all.each {|t| t.update(:completed => true) }
    end
  end
  
  def render
    section(id: "main") do
      input(id: "toggle-all", type: "checkbox").on(:click) { toggle_all }
      label(htmlFor: "toggle-all") { "Mark all as complete" }
      ul(id: "todo-list") do
        params[:todos].map do |todo|
          present TodoItem, todo: todo , key: todo.id
        end
      end
    end
  end
end
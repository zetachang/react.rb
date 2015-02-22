require "components/footer.react"
require "components/todo_item.react"
require "components/todo_list.react"

class TodoAppView
  include React::Component

  KEY_ENTER = 13

  params do
    requires :filter, values: ["all", "active", "completed"]
  end

  define_state(:todos) { [] }

  before_mount do
    Todo.on(:create)  { Todo.adapter.sync_models(Todo); reload_current_filter }
    Todo.on(:update)  { Todo.adapter.sync_models(Todo); reload_current_filter }
    Todo.on(:destroy) { Todo.adapter.sync_models(Todo); reload_current_filter }
  end

  before_receive_props do |next_props|
    apply_filter next_props[:filter]
  end

  def reload_current_filter
    apply_filter(params[:filter])
  end

  def apply_filter(filter)
    Todo.adapter.find_all(Todo) do |models|
      case filter
      when "all"
        self.todos = models
      when "active"
        self.todos = models.reject(&:completed)
      when "completed"
        self.todos = models.select(&:completed)
      end
    end
  end

  def handle_keydown(event)
    if event.key_code == KEY_ENTER
      value = event.target.value.strip
      Todo.create title: value, completed: false
      event.target.value = ""
    end
  end

  def render
    div do
      header(id: "header") do
        h1 { "Todos" }
        input(id: "new-todo", placeholder: "What needs to be done?").on(:key_down) { |e| handle_keydown(e) }
      end
      present TodoList, todos: self.todos
      present Footer, selected_filter: params[:filter]
    end
  end
end

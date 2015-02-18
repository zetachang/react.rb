require "components/footer.react"
require "components/todo_item.react"
require "components/todo_list.react"

class TodoAppView
  include React::Component

  KEY_ENTER = 13

  define_state(:todos) { [] }
  define_state(:current_filter) { "all" }

  before_mount :set_up

  def set_up
    Todo.on(:create)  { Todo.adapter.sync_models(Todo); reload_current }
    Todo.on(:update)  { Todo.adapter.sync_models(Todo); reload_current }
    Todo.on(:destroy) { Todo.adapter.sync_models(Todo); reload_current }
    router.update
  end

  def router
    @router ||= Vienna::Router.new.tap do |router|
      router.route('/:filter') do |params|
        apply_filter(params[:filter].empty? ? "all" : params[:filter])
      end
    end
  end

  def reload_current
    apply_filter(current_filter)
  end

  def apply_filter(filter)
    self.current_filter = filter
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
      present Footer, selected_filter: self.current_filter
    end
  end
end

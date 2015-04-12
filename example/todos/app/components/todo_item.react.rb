class TodoItem
  include React::Component
  KEY_ENTER = 13

  define_state(:editing) { false }
  define_state(:edit_text)

  before_mount :set_up

  def set_up
    self.edit_text = params[:todo].title
  end

  def finish_editing
    self.editing = false
    new_value = self.edit_text.strip
    if new_value.empty?
      params[:todo].destroy
    else
      params[:todo].update(title: new_value)
    end
  end

  def render
    li(class_name: {editing: self.editing}) do
      div(class_name: 'view') do
        input(class_name: "toggle", type: "checkbox", checked: params[:todo].completed)
        .on(:change) do |e|
          todo = params[:todo]
          todo.update(:completed => !todo.completed)
        end
        label { self.edit_text }.on(:double_click) do
          # set on state will trigger re-render, so we manipulate the DOM after render done
          self.set_state(editing: true) do
            self.refs[:input].dom_node.focus
          end
          self.edit_text = params[:todo].title
        end
        button(class_name: "destroy").on(:click) { params[:todo].destroy }
      end
      input(class_name: "edit", value: self.edit_text, ref: :input)
      .on(:blur) { finish_editing }
      .on(:change) {|e| self.edit_text = e.target.value }
      .on(:key_down) { |e| finish_editing if (e.key_code == KEY_ENTER) }
    end
  end
end

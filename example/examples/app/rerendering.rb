class Rerendering

  include React::Component

  class Child

    include React::Component

    define_state state_changes: 0
    require_param :param

    before_mount do
      @render_count = 0
      @render_difference = -1
      @render_saves = []
    end

    after_mount do
      @start_time = Time.now.to_i
      every(7) { puts "state  changes actual ticks = #{Time.now.to_i-@start_time}, calculated = #{(state_changes+1)*7}"; state_changes! state_changes+1}
    end

    def render
      puts "child rendering"
      @render_count = @render_count+1
      puts "ticks = #{(state_changes)*7} / #{(param)*11} / #{(Rerendering.exported_state_changes)*12}"
      if param + state_changes + Rerendering.exported_state_changes != @render_count + @render_difference
        @render_difference = param + state_changes + Rerendering.exported_state_changes - @render_count
        save = "Skipped a render @ #{Time.now.to_i-@start_time} secs when param = #{param} * 11, state_changes = #{state_changes} * 7, exported = #{Rerendering.exported_state_changes} * 12"
        @render_saves << save
        puts save
      end
      table do
        tr { "ticks = #{(state_changes)*7} / #{(param)*11} / #{(Rerendering.exported_state_changes)*12}".td(col_span: 3) }
        @render_saves.each do |save|
          tr { save.td(col_span: 3) }
        end
        tr { "child param has changed".td;        param.td;                                                        "times.".td  }
        tr { "internal state has changed".td;     state_changes.td;                                                "times.".td  }
        tr { "external state has changed".td;     Rerendering.exported_state_changes.td;                           "times.".td  }
        tr { "that's a total of".td;              (param + state_changes + Rerendering.exported_state_changes).td; "changes".td }
        tr { "And I have rendered a total of".td; (@render_count).td;                            "times".td   }
      end
    end

  end

  define_state parent_state_changes: 0
  define_state param_changes: 0
  export_state exported_state_changes: 0

  before_mount do
    @render_count = 0
  end

  after_mount do
    start_time = Time.now.to_i
    every(5) {  parent_state_changes! parent_state_changes+1  }
    every(11) { puts "param  changes actual ticks = #{Time.now.to_i-start_time}, calculated = #{(param_changes+1)*11}"; param_changes! param_changes+1 }
    every(12) { puts "export changes actual ticks = #{Time.now.to_i-start_time}, calculated = #{(exported_state_changes+1)*11}"; exported_state_changes! exported_state_changes + 1 }
  end

  def render
    puts "master_rendering"
    @render_count = @render_count+1
    div do
      "master has changed state a total of #{parent_state_changes + param_changes} times, and has rendered #{@render_count} times".br
      Child(param: param_changes)
    end
  end

end

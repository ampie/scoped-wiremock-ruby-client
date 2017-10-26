module Stopwatch
  def lap (next_step)
    lap_done
    @current_step_name=next_step
    @current_step_start=Time.now
    Kernel::puts("Now commencing task: '" + @current_step_name + "'")
  end
  def lap_done
    unless @current_step_name.nil?
      Kernel::puts("Task '" + @current_step_name + "' took " + (Time.now - @current_step_start).to_s)
    end
  end
end
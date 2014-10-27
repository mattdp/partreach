module SuppliersHelper
  #sort array, places many-state first
  def state_sort(states)
    in_progress = states.sort
    in_progress.insert(0,"unknown") if in_progress.delete("unknown")
    return in_progress
  end
end

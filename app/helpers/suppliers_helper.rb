module SuppliersHelper
  #sort array, places many-state first
  def state_sort(states)
    in_progress = states.sort
    in_progress.insert(0,"no_state") if in_progress.delete("no_state")
    return in_progress
  end
end

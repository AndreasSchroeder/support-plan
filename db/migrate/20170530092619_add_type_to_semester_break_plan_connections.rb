class AddTypeToSemesterBreakPlanConnections < ActiveRecord::Migration[5.0]
  def change
    add_column :semester_break_plan_connections, :typus, :integer
  end
end

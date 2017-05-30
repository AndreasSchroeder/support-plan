class AddTypeToSemesterPlanConnections < ActiveRecord::Migration[5.0]
  def change
    add_column :semester_plan_connections, :typus, :integer
  end
end

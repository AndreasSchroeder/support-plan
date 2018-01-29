require 'stringio'
class SemesterBreakPlanPdf < Prawn::Document
  include ApplicationHelper
  def initialize(plan)
    super()
    @plan = plan
    text_up
    table_content
  end

  def table_content
    # This makes a call to product_rows and gets back an array of data that will populate the columns and rows of a table
    # I then included some styling to include a header and make its text bold. I made the row background colors alternate between grey and white
    # Then I set the table column widths
    table(product_rows, :cell_style => { size: 12, height: 25}, column_widths: [125,375], header: true)
  end

    def text_up
    text "#{@plan.name}", size: 36, style: :bold
  end

  def product_rows
    shifts = eval(@plan.fixed_solution)
    p shifts
    tab = [[{content: 'Tag', font_style: :bold}, {content: 'Support', font_style: :bold}]]
    week = ""
    shifts.sort_by{|s| DaySlot.find(s[:slot].to_i).start}.each do |shift|
      if DaySlot.find(shift[:slot].to_i).start.strftime("%U").to_i != week
        if week != ""
          tab << [{content: " "}, {content: " "}]
        end
        week = DaySlot.find(shift[:slot].to_i).start.strftime("%U").to_i
      end
      tab << [{content: "#{german_dayname(DaySlot.find(shift[:slot]).start)}", align: :left}, {content: "#{User.find(shift[:user]).get_name_or_alias}", align: :right}]
    end
    tab
  end
end

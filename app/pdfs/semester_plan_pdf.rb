require 'stringio'
class SemesterPlanPdf < Prawn::Document
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
    table(product_rows, :cell_style => { size: 18, height: 30}, column_widths: [125,125,125,125], header: true)
  end

    def text_up
    text "#{@plan.name}", size: 36, style: :bold
    text "Treffen: #{@plan.meeting_day} um #{@plan.meeting_time}:00Uhr", size: 18, style: :bold
  end

  def product_rows
    tab = [[{content: 'Tag', font_style: :bold}, {content: 'Schicht', font_style: :bold}, {content: 'Support', font_style: :bold}, {content: 'Vertreter', font_style: :bold}]]
    day = ""
    eval(@plan.fixed_solution).each do |shift|
      col = []
      if TimeSlot.find(shift[:slot]).day == day
        day_data = {content: "", align: :left}
      else
        day = TimeSlot.find(shift[:slot]).day
        day_data = {content: day, align: :left}
      end
      col << day_data
      col << {content: "#{TimeSlot.find(shift[:slot]).start}:00 - #{TimeSlot.find(shift[:slot]).end}:00", align: :right}
      col << {content: "#{User.find(shift[:user]).last_name}", align: :right}
      col << {content: "#{User.find(shift[:co]).last_name}", align: :right}
      tab << col
    end
    tab
  end
end

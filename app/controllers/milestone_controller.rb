class MilestoneController < UserController
  before_action :auth_patient

  def create
   new_milestone = Milestone.create!(
        title: params[:title],
        datetime: params[:datetime],
        all_day: params[:allDay],
        location: params[:location],
        user_id: @current_user.id
    )
    render(json: new_milestone.as_json, status: 200)
  end

end

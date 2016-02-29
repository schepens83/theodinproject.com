class EventsController < ApplicationController
	before_action :set_event, only: [:show]

	def new
		@event = Event.new
	end

	def index
		@events = Event.all
	end

	def show
	end

	def create
		@user = User.find_by(name: cookies[:name])
		@event = @user.owner_events.build(event_params)

		if @event.save
			redirect_to @event, notice: 'Event was successfully created.'
		else
			render action: 'new', notice: 'Event creation was not successfull.'
		end
	end

	private

	def set_event
		@event = Event.find(params[:id])
	end

	def event_params
		params.require(:event).permit(:description, :location, :date)
	end
end

class AgentsController < ApplicationController
  def index
    @agents = Agent.page(params[:page]).per(10)
  end
end

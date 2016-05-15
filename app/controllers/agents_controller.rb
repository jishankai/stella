class AgentsController < ApplicationController
  def index
  end
  def search
    @agents = Agent.page(params[:page]).per(10)
  end
end

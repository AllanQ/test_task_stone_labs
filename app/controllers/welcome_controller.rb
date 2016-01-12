class WelcomeController < ApplicationController
  def index
    @notice = notice
    @alert = alert
  end
end

class ErrorsController < ApplicationController
  def not_found
    respond_to do |format|
      format.html { render :status => 404 }
      format.any { render :nothing => true, :status => 404 }
    end
  end

  def internal_server_error
    respond_to do |format|
      format.html { render :status => 500 }
      format.any { render :nothing => true, :status => 500 }
    end
  end
end

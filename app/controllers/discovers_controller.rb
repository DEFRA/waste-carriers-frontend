class DiscoversController < ApplicationController

  def logger
    Rails.logger
  end
  
  def new
    logger.debug 'New Smarter Answers Request'
    @discover = Discover.new
  end

  # POST /discovers
  # POST /discovers.json
  def create
    @discover = Discover.new(discover_params)
    
    if @discover.valid?
      logger.info 'Smarter Answers VALID, businessType: ' + @discover.businessType
    else
      logger.info 'Smarter Answers INVALID'
    end

    respond_to do |format|
      if @discover.valid?
	    if @discover.isUpper?
	      format.html { redirect_to Rails.configuration.waste_exemplar_eaupper_url }
	    else
	      logger.info 'Smarter Answers not upper'
	      session[:smarterAnswersBusiness] = @discover.businessType
        format.html { redirect_to newBusiness_path }
	      format.json { render action: 'show', status: :created, location: @discover }
	    end
      else
        logger.info 'Smarter Answers not valid'
        format.html { render action: 'new' }
        format.json { render json: @discover.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.

    # Never trust parameters from the scary internet, only allow the white list through.
    def discover_params
      params.require(:discover).permit(:businessType, :otherBusinesses, :onlyAMF, :constructionWaste, :wasteType_animal, :wasteType_mine, :wasteType_farm, :wasteType_other, :wasteType_none)
    end
end

class WorkingPlacesController < ApplicationController 
  def index
    @working_places = WorkingPlace.all.order(:working_place_number)#0505
  end
  
  def new
    #debugger
    @working_place = WorkingPlace.new
  end
  
  def create
    #debugger
   # @working_place = WorkingPlace.new(working_place_params)
    if WorkingPlace.create(working_place_params)  #@working_place.save
      flash.now[:success] = "拠点情報が登録されました"
      redirect_to working_places_path
    else
      flash.now[:notice] = "登録できません"
      render 'new'
    end
  end
  
  def edit
    @working_place = WorkingPlace.where(working_places: { id: params[:id] }).first
  end#working_place.
  
  def update
    @working_place = WorkingPlace.find(params[:id])
    if @working_place.update_attributes(working_place_params)
      flash[:success] = "拠点情報を変更しました。"
      redirect_to working_places_path
      # 更新に成功した場合を扱う。
    else
      render 'edit'
    end
  end
  
    
  def destroy
    WorkingPlace.find(params[:id]).destroy
    flash[:danger] = "拠点情報を削除しました。"
    redirect_to working_places_path
  end

  
  private
    def working_place_params
        params.require(:working_place).permit(
        :working_place_number,
        :working_place_name,
        :working_place_type
        )
    end

end
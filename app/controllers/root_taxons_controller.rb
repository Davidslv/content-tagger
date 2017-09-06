class RootTaxonsController < ApplicationController
  before_action :ensure_user_can_administer_taxonomy!

  def show
    @content_item = ContentItem.find!(params[:id])
  end

  def edit_all
    render :edit_all, locals: { form: RootTaxonsForm.new }
  end

  def update_all
    RootTaxonsForm.new(root_taxons_params).update
    redirect_to edit_all_root_taxons_path
  end

private

  def root_taxons_params
    params.require(:root_taxons_form).permit(root_taxons: [])
  end
end
